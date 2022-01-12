# Attachments RFC

This doc outlines how file attachments to disruptions will be handled. 📎


## Requirements

* Attachments are stored in AWS S3 (at least in production)
* Attachments on different disruptions can have the same filename
* Attachments can be deleted/"unattached" from their disruption
* Disruptions can have multiple attachment "kinds" (signage plan, shuttle
  diagram, etc.) and attachments can have different validations per kind
* Attachments can be downloaded via links in the UI
* Browser-supported attachment types can be displayed directly in the UI
* Attachments are uploaded via form submission or direct "drag to upload"
* Original filenames of attachments are stored and presented in the UI

### Nice-to-have

* Image attachments can be resized/converted
* Attachments are copied by `mix copy_db` in a usable form (file contents are
  not necessarily copied, but running the app locally produces working links)

### Non-requirements

* Attachments don't need to be uploaded directly to S3 from the browser
* Attachments don't need to be publicly accessible or have stable public URLs


## Proposal

[Waffle] appears to be the most widely used off-the-shelf solution for handling
file uploads and downloads in Elixir. On investigation of this library and its
[Ecto support module][Waffle.Ecto], it appears to offer everything we need for
this feature, and also checks off some nice-to-haves.

The docs have a [complete example module][example] which includes dynamic
storage paths, validation, and producing multiple "versions" using ImageMagick,
which might be useful to refer to. This does not include Ecto integration.

[Waffle]: https://hexdocs.pm/waffle/Waffle.html
[Waffle.Ecto]: https://hexdocs.pm/waffle_ecto/Waffle.Ecto.html
[example]: https://hexdocs.pm/waffle/s3.html

### Terminology

**"Definition module"** is a module which uses `Waffle.Definition` and
conceptually represents a "kind of upload" (an "avatar" is the example used in
the docs). Such modules gain an API to `store`, `delete`, and retrieve the `url`
of a file, and can override several callbacks to control how those things happen
or add validations, transformations, or "versions" (variants, e.g. thumbnails).

Filename is the primary identifier used by Waffle. **"Scope"** refers to any
Elixir term passed, together with a filename, to one of the definition module's
functions. The filename-plus-scope then flows through to the callbacks. For
example, if an Ecto "user" struct were used as the scope, this would allow
storing avatars under different paths per user by incorporating the user ID,
instead of all avatars occupying a single global namespace.

### Storage

Waffle has a first-party S3 storage adapter which uses ExAws for configuration,
the same AWS library we already use. Storage can be configured per environment,
allowing us to use local storage for testing and S3 storage when deployed:

```elixir
# config/config.exs
config :waffle, storage: Waffle.Storage.Local

# config/prod.exs
config :waffle, storage: Waffle.Storage.S3, bucket: {:system, "S3_BUCKET"}
```

Most storage parameters (path, ACLs, HTTP headers) can be set either globally in
the app config or per-attachment using callbacks.

### Data Model

Since the "types" of attachments we want to support have a lot of behavior in
common, and easily extending the system to support new types is desired, we can
use a single Ecto schema and definition module for all of them. In principle it
even appears possible for both of these to be the same module — the docs use
separate modules since their example of a "user" who has an "avatar" involves
two separate concepts.

Here is what a combined approach might look like:

```elixir
defmodule Arrow.Disruption.Attachment do
  use Ecto.Schema
  use Waffle.Definition
  use Waffle.Ecto.Definition
  use Waffle.Ecto.Schema

  @kinds ~w(miscellaneous cr_schedule shuttle_diagram signage_plan)
  @versions ~w(original preview)a

  schema "disruption_attachments" do
    belongs_to :disruption, Arrow.Disruption

    field :kind, :string
    field :file, __MODULE__.Type

    timestamps(type: :utc_datetime)
  end

  def changeset(data, params \\ %{}) do
    cast_attachments(data, params, [:file])
  end

  # derive path from disruption ID
  def storage_dir(version, {_file, %__MODULE__{disruption_id: id}}) do
    "attachments/#{id}/#{version}"
  end

  # example of validation per kind of attachment
  def validate({%{file_name: name}, %__MODULE__{kind: "cr_schedule"}}) do
    case name |> Path.extname() |> String.downcase() in ~w(pdf xlsx) do
      true -> :ok
      false -> {:error, "must be a PDF or Excel sheet"}
    end
  end

  # example of transforming specific kinds of attachment
  def transform(:original, _), do: :noaction

  def transform(:preview, {_file, %__MODULE__{kind: "shuttle_diagram"}}) do
    {:convert, "-strip -thumbnail x200 -limit area 10MB -limit disk 100MB"}
  end

  def transform(:preview, _), do: :skip
end
```

Note using a record ID as part of the storage path requires that the record be
persisted before the attachment is casted/saved. In the above example the
disruption ID is used rather than the attachment ID, so this would only come
into play when a disruption is newly created. The recommended solution is to
use `Multi`, which does mean we can't use `cast_assoc` directly.


## Drawbacks

* With the `Waffle.Ecto` integration, `cast_attachments` immediately stores the
  file data to S3 if it is valid. If something goes wrong later in the process
  and the Attachment record is not persisted, there is now a "disconnected"
  file in S3, and we need to account for this and do the cleanup ourselves.
  This is in contrast to alternatives (see below), in which casting/validation
  is not necessarily coupled to uploading.

* The general quality of Waffle's code, APIs, and documentation seems a bit
  uneven. For example, there are no typespecs; there are no behaviours for the
  callbacks; the `File` struct passed to callbacks is [undocumented][q1];
  variants are defined using an also-undocumented [magic module attribute][q2];
  deleting a file [always returns `:ok`][q3] even if it fails. Individually
  these are minor papercuts, but they add up to a slightly shaky foundation.

[q1]: https://github.com/elixir-waffle/waffle/blob/master/lib/waffle/file.ex#L2
[q2]: https://github.com/elixir-waffle/waffle/blob/master/lib/waffle/definition/versioning.ex#L48
[q3]: https://github.com/elixir-waffle/waffle/issues/86


## Alternatives

### Capsule

[Capsule](https://github.com/elixir-capsule/capsule) appears to be the only
other file upload library on Hex with significant use (1k recent downloads,
versus Waffle's 60k). Its author describes it as "experimental and still in
active development ... Use at your own risk." Despite this, it seems to have a
more well-thought-out architecture than Waffle, focused on small composable
primitives. It also has first-party Ecto and S3 storage integrations.

For us, since our use case aligns so well with what Waffle does out of the box,
Capsule almost looks like a kit for building our own version of Waffle. Notably,
it'd be on us to implement image variants and conversions (the [Mogrify] library
at least provides a nice wrapper around the ImageMagick command line).

[Mogrify]: https://hexdocs.pm/mogrify/readme.html

### Roll our own

Since `Plug.Upload` and `ExAws.S3` already handle most of the "hard parts" of
accepting file uploads, storing them in S3, and generating URLs for them, it
doesn't seem out of the question for us to write all the glue code ourselves.

Below is a sketch of this approach, taking cues from Waffle. For error handling,
`insert` and `delete` could wrap their operations in `Multi` steps; the module
could then provide a `cleanup` function that accepts and "passes through" a
transaction result and, if the result was failure, uses the Multi data to "roll
back" the upload steps by deleting the objects from S3.

In some ways, this approach appears cleaner than either Waffle or Capsule,
though of course high-level sketches always _appear_ clean. In any case it is
an intriguing option.

```elixir
defmodule Arrow.Disruption.Attachment do
  use Ecto.Schema

  @kinds ~w(miscellaneous cr_schedule shuttle_diagram signage_plan)
  @variants ~w(original preview)a

  # this would be a module that implements a common storage adapter behaviour,
  # using `ExAws.S3` in production and the local file system in dev/test
  @storage Application.compile_env(:arrow, :attachment_storage)

  schema "disruption_attachments" do
    belongs_to :disruption, Arrow.Disruption

    field :kind, :string
    field :filename, :string
    field :upload, :any, virtual: true

    timestamps(type: :utc_datetime)
  end

  def changeset(data, %{"upload" => %Plug.Upload{...}}) do
    # validate the upload as needed and store it on the virtual `upload` field
  end

  def insert(%__MODULE__{...}) do
    # get file contents from the `upload` field
    # use Mogrify to generate variants if applicable
    # use `@storage` to upload them to the `path`
    # insert the record
  end

  def delete(%__MODULE__{...}) do
    # use `@storage` to delete the objects for all variants
    # delete the record
  end

  def url(%__MODULE__{...}, variant \\ :original) do
    # use `@storage` to get a signed URL using the `path`
  end

  defp path(%__MODULE__{...}, variant \\ :original) do
    # generate the path using the disruption ID and variant
  end
end
```
