defmodule HexletBasicsWeb.UserController do
  use HexletBasicsWeb, :controller
  alias HexletBasics.{User, Repo, UserManager, UserManager.Guardian, StateMachines.UserStateMachine}
  alias HexletBasics.{Email, Notifier}
  alias HexletBasicsWeb.Plugs.CheckAuthentication
  alias HexletBasicsWeb.Plugs.DetectLocaleByHost

  plug CheckAuthentication when action in [:new, :create]
  plug DetectLocaleByHost when action in [:new]

  def new(conn, _params) do
    changeset = User.registration_changeset(%User{}, %{})
    meta_attrs = [
      %{property: "og:type", content: 'website'},
      %{property: "og:title", content: gettext("Code Basics Registration Title")},
      %{property: "og:description", content: gettext("Code Basics Registration Description")},
      %{property: "og:image", content: Routes.static_url(conn, "/images/logo.png")},
      %{property: "og:url", content: Routes.page_url(conn, :index)},
      %{property: "description", content: gettext("Code Basics Registration Description")},
      %{property: "image", content: Routes.static_url(conn, "/images/logo.png")}
    ]
    link_attrs = [
      %{rel: "canonical", href: Routes.page_url(conn, :index)},
      %{rel: 'image_src', href: Routes.static_url(conn, "/images/logo.png")}
    ]

    title_text = gettext("Code Basics Registration Title")

    render(conn, "new.html", changeset: changeset, meta_attrs: meta_attrs, link_attrs: link_attrs, title: title_text)
  end

  def create(conn, %{"user" => params}) do
    %{assigns: %{locale: locale}} = conn
    changeset = User.registration_changeset(%User{}, Map.put(params, "locale", locale))

    case Repo.insert(changeset) do
      {:ok, user} ->
        email =
          Email.confirmation_html_email(
            conn,
            user,
            Routes.user_url(conn, :confirm, confirmation_token: user.confirmation_token)
          )

        email
        |> Notifier.send_email(user)

        {:ok, %User{state: state}} =
          Machinery.transition_to(user, UserStateMachine, "waiting_confirmation")

        user
        |> User.state_changeset(%{state: state})
        |> Repo.update()

        conn
        |> put_flash(:info, gettext("User created! Check your email for confirm registration"))
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def confirm(conn, params) do
    user = UserManager.user_get_by(confirmation_token: params["confirmation_token"])

    if user do
      if User.active?(user) do
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/")
      else
        {:ok, %User{state: state}} = Machinery.transition_to(user, UserStateMachine, "active")

        user
        |> User.state_changeset(%{state: state})
        |> Repo.update()

        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, gettext("Registration confirmed! Welcome!"))
        |> redirect(to: "/")
      end
    else
      conn
      |> put_flash(:error, gettext("User not found"))
      |> redirect(to: "/")
    end
  end

  def resend_confirmation(conn, %{"user_id" => user_id} = params) do
    user = UserManager.get_user!(user_id)
    changeset = User.resend_confirmation_changeset(user)
    redirect_to = params["redirect_to"] || Routes.page_path(conn, :index)

    case Repo.update(changeset) do
      {:ok, user} ->
        email =
          Email.confirmation_html_email(
            conn,
            user,
            Routes.user_url(conn, :confirm, confirmation_token: user.confirmation_token)
          )

        email
        |> Notifier.send_email(user)

        conn
        |> put_flash(
          :info,
          gettext(
            "We sent an email to confirm the email - %{email}, follow the link from the email to complete the procedure.",
            email: user.email
          )
        )
        |> redirect(to: redirect_to)

      {:error, _} ->
        conn
        |> put_flash(
          :error,
          gettext(
            "Something went wrong! Please contact support <a href=mailto:support@hexlet.io> support@hexlet.io </a>."
          )
        )

        |> redirect(to: redirect_to)
    end
  end
end
