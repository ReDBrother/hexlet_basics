defmodule HexletBasicsWeb.Language.Module.LessonControllerTest do
  use HexletBasicsWeb.ConnCase
  alias HexletBasics.UserManager.Guardian

  test "show", %{conn: conn} do
    lesson = insert(:language_module_lesson)
    module = lesson.module
    language = lesson.language

    conn = conn
           |> get(language_module_lesson_path(conn, :show, language.slug, module.slug, lesson.slug))
    assert html_response(conn, 200)
  end

  test "show for signed user", %{conn: conn} do
    user = insert(:user)
    lesson = insert(:language_module_lesson)
    module = lesson.module
    language = lesson.language

    conn = conn
           |> Guardian.Plug.sign_in(user)
           |> get(language_module_lesson_path(conn, :show, language.slug, module.slug, lesson.slug))
    assert html_response(conn, 200)
  end

  test 'index', %{conn: conn} do
    module = insert(:language_module)
    language = module.language
    conn = get conn, language_module_lesson_path(conn, :index, language.slug, module.slug)
    assert html_response(conn, 200)
  end
end

