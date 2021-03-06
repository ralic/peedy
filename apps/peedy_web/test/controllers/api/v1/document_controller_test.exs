defmodule PeedyWeb.Api.V1.DocumentControllerTest do
  use PeedyWeb.ConnCase
  use PeedyWeb.Case
  alias PeedyF.{Repo, Document, Watermark}

  @watermark_id Ecto.UUID.generate()

  setup do
    on_exit fn -> Toniq.failed_jobs |> Enum.map(&Toniq.delete/1) end
    _ =
      %Watermark{id: @watermark_id, input: "Jim Bob", output: <<1, 2, 3>>}
      |> Repo.insert!()
    document =
      %Document{
        id: Ecto.UUID.generate(),
        input: <<1, 2>>,
        output: <<3, 4>>,
        input_hash: "abc",
        output_hash: "def",
        watermark_id: @watermark_id
      }
      |> Repo.insert!()

    {:ok, %{document: document}}
  end

  test "show returns existing document if present", %{document: document} do
    conn = get(build_conn(), document_path(build_conn(), :show, document))
    {"content-disposition", attachment} = Enum.find(conn.resp_headers, nil, fn {k, _v} ->
      k === "content-disposition"
    end)

    assert conn.resp_body == <<3, 4>>
    refute is_nil(attachment)
  end

  test "show returns 404 if not present" do
    conn = get(build_conn(), document_path(build_conn(), :show, %Document{id: Ecto.UUID.generate()}))

    assert conn.status == 404
  end

  test "create returns 200" do
    upload = %Plug.Upload{
      content_type: "application/pdf",
      path: "test/fixtures/images/bill.pdf",
      filename: "bill.pdf"
    }
    conn = post(build_conn(), "/api/v1/documents?watermark=Ricky%20Bobby&callback_url=lol", file: upload)

    assert conn.status == 200
  end

  test "create returns 400 if params are missing" do
    conn = post(build_conn(), document_path(build_conn(), :create))

    assert conn.status == 400
  end
end
