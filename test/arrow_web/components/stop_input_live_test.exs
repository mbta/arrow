defmodule ArrowWeb.StopInputTest do
  use ArrowWeb.ConnCase

  import Arrow.Factory
  import LiveIsolatedComponent
  import Phoenix.LiveViewTest

  describe "autocomplete functionality" do
    test "can select a single-character stop by ID", %{conn: _conn} do
      _stop = insert(:stop, %{stop_id: "1"})

      route_stop_changeset = :route_stop |> build() |> Arrow.Shuttles.RouteStop.changeset(%{})
      form = Phoenix.Component.to_form(route_stop_changeset)

      {:ok, view, _html} =
        live_isolated_component(ArrowWeb.StopInputTest.TestFormLiveComponent, %{
          form: form,
          id: "test-id"
        })

      # view
      # |> element("#route_stop_display_stop_id_live_select_component")
      # |> render()
      # |> IO.inspect()

      view
      |> element("form")
      |> render_change(%{display_stop_id: "1"})
      |> IO.inspect()

      view
      |> element("#_display_stop_id_live_select_component")
      |> render_hook("live_select_change", %{"id" => "test-id", "text" => "1"})
      |> IO.inspect()
    end
  end

  defmodule TestFormLiveComponent do
    use ArrowWeb, :live_component

    attr :id, :string, required: true
    attr :form, :any, required: true

    def render(assigns) do
      ~H"""
      <div id={@id}>
        <.simple_form :let={f} for={@form}>
          <.live_component
            module={ArrowWeb.StopInput}
            id="test-live-select-id"
            field={f[:display_stop_id]}
          />
        </.simple_form>
      </div>
      """
    end
  end
end
