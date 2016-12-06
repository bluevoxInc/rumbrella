defmodule Rumbl.VideoControllerTest do
  # require Logger
  use Rumbl.ConnCase

  alias Rumbl.Video
  @valid_attrs %{description: "some content", title: "some content", url: "some content"}

  @invalid_attrs %{}

  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))

  defp insert_user_video user do
    insert_video user, title: "funny cats"
  end

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag login_as: "gilligan"
  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_user_video user
    other_video = insert_video(insert_user(username: "other"), title: "another video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "gilligan"
  test "show user video", %{conn: conn, user: user} do
    user_video = insert_user_video user
    conn = get conn, video_path(conn, :show, user_video)
    assert html_response(conn, 200) =~ "Show video"
  end

  @tag login_as: "gilligan"
  test "renders form for editing user video", %{conn: conn, user: user} do
    user_video = insert_user_video user
    conn = get conn, video_path(conn, :edit, user_video)
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "gilligan"
  test "update user video and redirects when using valid data", %{conn: conn, user: user} do
    user_video = insert_user_video user
    conn = put conn, video_path(conn, :update, user_video), video: @valid_attrs

    user_video_mod = Repo.get_by!(Video, @valid_attrs)
    assert user_video.id == user_video_mod.id

    # Logger.debug "*****DEBUGGING******** #{inspect Repo.get_by!(Video, @valid_attrs)}"
    # Logger.debug "*****DEBUGGING******** #{inspect user_video}"

    assert redirected_to(conn) == video_path(conn, :show, user_video_mod)
  end

  @tag login_as: "gilligan"
  test "does not update user video and renders errors when using invalid data", %{conn: conn, user: user} do
    user_video = insert_user_video user
    conn = put conn, video_path(conn, :update, user_video), video: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "gilligan"
  test "deletes user video", %{conn: conn, user: user} do
    user_video = insert_user_video user
    conn = delete conn, video_path(conn, :delete, user_video)
    assert redirected_to(conn) == video_path(conn, :index)
    refute Repo.get(Video, user_video.id)
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "gilligan"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "gilligan"
  test "does not create video and renders errors when invalid params", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ ~r/please check the errors below/i
    assert video_count(Video) == count_before
  end

  @tag login_as: "gilligan"
  test "rejects actions against access by other users", %{user: owner, conn: conn} do
    video = insert_video(owner, @valid_attrs)
    non_owner = insert_user(user_name: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      put(conn, video_path(conn, :update, video, video: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, video_path(conn, :delete, video))
    end
  end


end

