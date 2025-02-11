defmodule ArrowWeb.CoreComponentsTest do
  use ArrowWeb.ConnCase, async: true

  import ArrowWeb.CoreComponents
  import Phoenix.Component
  import Phoenix.LiveViewTest

  describe "navbar" do
    test "link corresponding to current page has .btn-primary" do
      assigns = %{page: "/shuttles"}

      primary_links =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.find("a.btn-primary")

      assert [primary_link] = primary_links

      assert Floki.text(primary_link) =~ "Shuttle Definitions"
    end

    test "other v2 page links have .btn-outline-secondary" do
      assigns = %{page: "/shuttles"}

      secondary_links =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.find("a.btn-outline-secondary")

      assert length(secondary_links) == 3
    end

    test "first link is to /disruptionsv2 when not on Disruptions page" do
      assigns = %{page: "/shapes"}

      hrefs =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.attribute("a", "href")

      assert ["/disruptionsv2" | _] = hrefs
    end

    test "first link is to /disruptionsv2/new when on Disruptions page, with permission" do
      assigns = %{page: "/disruptionsv2", create_disruption_permission?: true}

      hrefs =
        ~H"""
        <.navbar page={@page} create_disruption_permission?={@create_disruption_permission?} />
        """
        |> rendered_to_string()
        |> Floki.attribute("a", "href")

      assert ["/disruptionsv2/new" | _] = hrefs
    end

    test "first link is to /disruptionsv2 when on Disruptions page, without permission" do
      assigns = %{page: "/shapes"}

      hrefs =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.attribute("a", "href")

      assert ["/disruptionsv2" | _] = hrefs
    end

    test "renders link to v1 homepage with .btn-warning class" do
      assigns = %{page: "/stops"}

      warning_buttons =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.find(".btn-warning")

      assert [warning_button] = warning_buttons

      assert Floki.text(warning_button) == "Switch to Arrow v1"
    end
  end
end
