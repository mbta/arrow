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
        |> Floki.find("a.btn-secondary")

      assert [current_page_link] = current_page_links

      assert Floki.text(current_page_link) =~ "Shuttle definitions"
      assert Floki.attribute(current_page_link, "href") == []
    end

    test "other v2 page links have .btn-outline-secondary and href" do
      assigns = %{page: "/shuttles"}

      secondary_links =
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
        |> Floki.find("a.btn-outline-secondary")

      assert length(secondary_links) == 3
      assert length(Floki.attribute(secondary_links, "href")) == 3
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

    test "first link is to /disruptionsv2/new when on Disruptions page, with create permission" do
      assigns = %{page: "/disruptionsv2", create_disruption_permission?: true}

      hrefs =
        ~H"""
        <.navbar page={@page} create_disruption_permission?={@create_disruption_permission?} />
        """
        |> rendered_to_string()
        |> Floki.attribute("a", "href")

      assert ["/disruptionsv2/new" | _] = hrefs
    end

    test "first link is to /disruptionsv2 when on Disruptions page, without create permission" do
      assigns = %{page: "/disruptionsv2"}

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

    test "raises an exception if @page is unrecognized" do
      assigns = %{page: "/unknown_page"}

      expect_msg = "navbar component used on an unrecognized page: /unknown_page"

      ExUnit.Assertions.assert_raise(RuntimeError, expect_msg, fn ->
        ~H"""
        <.navbar page={@page} />
        """
        |> rendered_to_string()
      end)
    end
  end
end
