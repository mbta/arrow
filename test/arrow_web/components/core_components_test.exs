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

      assert [current_page_link] = current_page_links

      assert LazyHTML.text(current_page_link) =~ "Shuttles"
      assert LazyHTML.attribute(current_page_link, "href") == []
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

      assert length(secondary_links) == 3
      assert length(LazyHTML.attribute(secondary_links, "href")) == 3
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

      assert [warning_button] = warning_buttons

      assert LazyHTML.text(warning_button) == "Switch to V1"
    end
  end
end
