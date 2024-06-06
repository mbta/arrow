defmodule ArrowWeb.ErrorViewTest do
  use ArrowWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(ArrowWeb.ErrorView, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ArrowWeb.ErrorView, "500", "html", []) == "Internal Server Error"
  end

  test "renders 404.json" do
    assert ArrowWeb.ErrorView
           |> render_to_string("404", "json", [])
           |> Jason.decode!() == %{
             "errors" => [
               %{
                 "code" => "not_found",
                 "source" => %{"parameter" => "id"},
                 "status" => "404",
                 "title" => "Resource Not Found"
               }
             ],
             "jsonapi" => %{"version" => "1.0"}
           }
  end
end
