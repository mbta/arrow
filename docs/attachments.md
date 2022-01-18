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

Since `Plug.Upload` and `ExAws.S3` already handle most of the "hard parts" of
accepting file uploads, storing them in S3, and generating URLs for them, it's
an entirely reasonable option for us to glue them together ourselves, without a
third-party library. Libraries are, however, explored in the **Alternatives**.

### Relevant APIs

* When a file is uploaded from a `Phoenix.HTML.Form.file_input/3`, Phoenix
  automatically receives and stores the file in a temporary location on disk
  that is deleted when the request process dies, and generates a `Plug.Upload`
  struct for it in the request's `params`. This has `filename`, `content_type`,
  and `path` fields.

* `ExAws.S3.put_object/4` allows uploading a binary to a specified path.
  Initially this might be the simplest way to handle uploads, but if we need to
  account for very large files, there is also `ExAws.S3.upload/4` which allows
  streaming data directly from disk (instead of reading the whole file into a
  binary in memory first).

* `ExAws.S3.delete_object/3` can delete the objects we `put`.

* `ExAws.S3.presigned_url/5` generates a pre-signed URL for an object (enabling
  it to be accessed without authentication for a limited time).

### Variants

For generating "variants" of image attachments, such as thumbnails, we can use
the [Mogrify](https://hexdocs.pm/mogrify/) library, a convenient wrapper around
the ImageMagick command-line tool. This would require adding a new system-level
dependency both for developers and in the production images, but it doesn't seem
like there are any good pure-Elixir options for this.

### Data Model

Since the "types" of attachments we want to support have a lot of behavior in
common, and easily extending the system to support new types is desired, we can
use a single Ecto schema for all of them. Below is a sketch of this approach.

In this sketch, full storage paths for an attachment are generated when needed,
and only the original filename is stored in our database — this allows handling
variants without much extra effort, since the desired variant can be part of the
call to generate the path (this mirrors how Waffle works).

Comments tagged with `[v]` indicate logic that would only be needed once we
implement support for image variants.

```elixir
defmodule Arrow.Disruption.Attachment do
  use Ecto.Schema

  @kinds ~w(miscellaneous cr_schedule shuttle_diagram signage_plan)

  # Module that implements a common storage adapter behaviour, using `ExAws.S3`
  # in production and the local file system in dev/test. The callbacks could be
  # `put`, `delete`, and `url`, each accepting a file path.
  @storage Application.compile_env(:arrow, :attachment_storage)

  schema "disruption_attachments" do
    belongs_to :disruption, Arrow.Disruption

    field :kind, :string
    field :filename, :string

    # actual type is a Plug.Upload struct
    field :upload, :any, virtual: true

    timestamps(type: :utc_datetime)
  end

  def changeset(data, params \\ %{}) do
    # Accept an "upload" param that is the Plug.Upload and apply validations
    # (e.g. if the `kind` is `shuttle_diagram`, validate that the file is a PNG,
    # based on name or `content_type`), then assign it to the `upload` field.
  end

  def insert(%__MODULE__{}) do
    # Return a `Multi` with an `insert` step that sets the `filename` from the
    # `upload` field and inserts the Attachment, and a `run` step that uploads
    # the file itself to the `path/2`, using `@storage.put`.
    #
    # [v] Instead of the single upload step, generate a step for each of the
    #     `variants`, using `convert` to produce them. Suggestion: identifiers
    #     for the steps could be `{:upload, variant}`.
  end

  def delete(%__MODULE__{}) do
    # Return a `Multi` that includes a `run` step to delete the Attachment's
    # file, using `path/2` and `@storage.delete`, and a `delete` step to delete
    # the Attachment itself.
    #
    # [v] This would also include a `run` to delete each variant from storage.
  end

  # Function that accepts and returns (unchanged) a transaction result. If the
  # result is a Multi error, and the changes that succeeded include any of the
  # `run` steps we generate in `insert` to upload files, use `@storage.delete`
  # to clean them up. This implies those steps need to return a value that tells
  # us where the file is.
  #
  # TBD: What to do if the cleanup deletion fails? Ignore it?
  #
  # TBD: Do we need to handle a `delete` multi that failed? The file is already
  #      deleted... could move it to a "trash" prefix we periodically clean out,
  #      and restore it to original location on error, but maybe too much work

  def cleanup({:ok, _} = result), do: result
  def cleanup({:error, _} = result), do: result
  def cleanup({:error, _operation, _result, changes}) do
    # ...
  end

  def url(%__MODULE__{}, variant \\ :original) do
    # Call `path/2` and pass the result to `@storage.url`.
  end

  defp path(%__MODULE__{}, variant \\ :original) do
    # Generate a storage path for the file. This could be in the form:
    #   /<disruption ID>/<variant>/<filename>
    # To be able to use the disruption ID, a new disruption would need to have
    # already been inserted before `Attachment.insert` is called (probably in a
    # multi of its own, to which the Attachment multi is appended).
    #
    # [v] The `variant` argument would only have to exist once we add variants.
    #     Before that, we can just hard-code that path segment as `original`.
  end

  defp variants(%__MODULE__{}) do
    # [v] Determine what variants the Attachment should have based on `kind`.
  end

  # [v] Given a local file path and a variant, perform any required transforms
  #     for the variant and return a path where the transformed file is saved.
  #     In this example we assume `:original` and `:preview` variants exist.

  defp convert(path, :original), do: path
  defp convert(path, :preview) do
    # Use Mogrify to open the file path, convert it, and save it under a new
    # temp file path, which we return
  end
end
```


## Alternatives

### Waffle

[Waffle] appears to be the most widely used off-the-shelf solution for handling
file uploads in Elixir.

Points in its favor include a first-party [Ecto support module][Waffle.Ecto], an
S3 storage adapter which uses ExAws for configuration (the same AWS library we
already use), and ImageMagick support for producing multiple variants of image
uploads. The docs have a [complete example module][example] which uses most
features of the library, other than the Ecto integration.

[Waffle]: https://hexdocs.pm/waffle/Waffle.html
[Waffle.Ecto]: https://hexdocs.pm/waffle_ecto/Waffle.Ecto.html
[example]: https://hexdocs.pm/waffle/s3.html

The main point against it is the general uneven quality of its code, APIs, and
documentation. For example, there are no typespecs; there are no behaviours for
callbacks; the `File` struct passed to callbacks is [undocumented][q1]; variants
are defined using an also-undocumented [magic module attribute][q2]; deleting a
file [always returns `:ok`][q3] even if it fails. Individually these are minor
papercuts, but they add up to a slightly shaky foundation.

[q1]: https://github.com/elixir-waffle/waffle/blob/master/lib/waffle/file.ex#L2
[q2]: https://github.com/elixir-waffle/waffle/blob/master/lib/waffle/definition/versioning.ex#L48
[q3]: https://github.com/elixir-waffle/waffle/issues/86

Another downside is that the Ecto integration immediately uploads the file to
storage upon casting (if it passes validation), and has no built-in mechanism
to clean up "disconnected" files in S3 if saving the record fails later on.
Although with the proposed solution we have to implement the upload/cleanup
lifecycle ourselves anyway, it means the existence of the Ecto integration
isn't as much of a time-saver as it seems.

### Capsule

[Capsule](https://github.com/elixir-capsule/capsule) appears to be the only
other file upload library on Hex with significant use (1k recent downloads,
versus Waffle's 60k). Its author describes it as "experimental and still in
active development ... Use at your own risk." Despite this, it seems to have a
more well-thought-out architecture than Waffle, focused on small composable
primitives. It also has first-party Ecto and S3 storage integrations.

The main strike against Capsule other than its immaturity is that because it's
relatively low-level, it doesn't seem to get us much _beyond_ the roll-our-own
approach. Notably, we'd still have to implement variants and ImageMagick
conversions from scratch.
