defmodule ArrowWeb.CoreComponentsTest do
  use ArrowWeb.ConnCase

  import ArrowWeb.CoreComponents
  import Phoenix.Component
  import Phoenix.LiveViewTest

  describe "navbar" do
    test "link corresponding to current page has .btn-secondary and no href" do
      assigns = %{page: "/shuttles"}

      current_page_links =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("a.btn-secondary")

      assert [{_a, _css, [inner_text]}] = LazyHTML.to_tree(current_page_links)
      assert inner_text =~ "Shuttle"
    end

    test "other v2 page links have .btn-outline-secondary and href" do
      assigns = %{page: "/shuttles"}

      secondary_links =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("a.btn-outline-secondary")
        |> LazyHTML.to_tree()

      assert [
               {"a", [_, {"href", "/"}], _},
               {"a", [_, {"href", "/shapes"}], _},
               {"a", [_, {"href", "/stops"}], _}
             ] = secondary_links
    end

    test "first link is to / when not on Disruptions page" do
      assigns = %{page: "/shapes"}

      hrefs =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("a")
        |> LazyHTML.attribute("href")

      assert ["/" | _] = hrefs
    end

    test "first link is to /disruptions/new when on Disruptions page, with create permission" do
      assigns = %{page: "/", create_disruption_permission?: true}

      hrefs =
        ~H"""
        <.navbar page={@page} create_disruption_permission?={@create_disruption_permission?} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("a")
        |> LazyHTML.attribute("href")

      assert ["/disruptions/new" | _] = hrefs
    end

    test "first link is to / when on Disruptions page, without create permission" do
      assigns = %{page: "/"}

      hrefs =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("a")
        |> LazyHTML.attribute("href")

      assert ["/" | _] = hrefs
    end

    test "renders link to v1 homepage with .btn-warning class" do
      assigns = %{page: "/stops"}

      warning_buttons =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> LazyHTML.from_fragment()
        |> LazyHTML.query(".btn-warning")
        |> LazyHTML.to_tree()

      assert [{"a", _attributes, ["Switch to V1"]}] = warning_buttons
    end
  end
end
