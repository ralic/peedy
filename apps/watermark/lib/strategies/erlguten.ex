defmodule Watermark.Strategies.Erlguten do
  @moduledoc """
  Create a watermark using Erlguten. Needs more work as Erlguten does not handle
  text opacity.
  """
  @behaviour WatermarkBehaviour

  def new(text) when is_binary(text) do
    pdf_pid = new_pdf()
    exported =
      pdf_pid
      |> set_pagesize(:a4)
      |> set_page(1)
      |> set_font("Helvetica", 60)
      |> set_text_rendering(:fill)
      |> set_fill_gray(0.9)
      |> move_and_show_rot(200, 500, text, 315)
      |> export()

    output_path = write_file("#{System.tmp_dir!()}/#{String.replace(text, ~r/\s/, "")}.pdf", exported)
    close_pdf(pdf_pid)
    output_path
  end

  defp new_pdf, do: :eg_pdf.new()

  defp set_pagesize(pid, size) do
    :ok = :eg_pdf.set_pagesize(pid, size)
    pid
  end

  defp set_page(pid, page) do
    :ok = :eg_pdf.set_page(pid, page)
    pid
  end

  defp set_font(pid, font_family, font_size) do
    :ok = :eg_pdf.set_font(pid, String.to_charlist(font_family), font_size)
    pid
  end

  defp set_text_rendering(pid, mode) do
    :ok = :eg_pdf.set_text_rendering(pid, mode)
    pid
  end

  defp set_fill_gray(pid, color) do
    :ok = :eg_pdf.set_fill_gray(pid, color)
    pid
  end

  defp move_and_show_rot(pid, x, y, text, rot) do
    :ok = :eg_pdf_lib.moveAndShowRot(pid, x, y, String.to_charlist(text), rot)
    pid
  end

  defp export(pid) do
    :eg_pdf.export(pid)
  end

  defp write_file(path, {content, _}) do
    {:ok, _} = File.open(path, [:write], fn f ->
      IO.write(f, content)
    end)
    path
  end

  defp close_pdf(pid) do
    :ok = :eg_pdf.delete(pid)
    pid
  end
end
