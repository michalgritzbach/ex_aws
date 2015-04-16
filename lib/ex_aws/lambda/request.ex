defmodule ExAws.Lambda.Request do
  def request(data, action, path, adapter, params \\ [], headers \\ []) do
    {_, http_method} = ExAws.Lambda.Impl |> ExAws.Actions.get(action)
    path = [path, params |> URI.encode_query] |> IO.iodata_to_binary

    headers = [
      {"content-type", "application/json"},
      {"x-amz-content-sha256", ""} |
      headers
    ]
    ExAws.Request.request(http_method, adapter.config |> url(path), data, headers , adapter)
    |> parse(adapter.config)
  end

  def parse({:error, result}, _), do: {:error, result}
  def parse({:ok, body}, config) do
    case config[:json_codec].decode(body) do
      {:ok, result} -> {:ok, result}
      {:error, _}   -> {:error, body}
    end
  end

  defp url(config, path) do
    [
      Keyword.get(config, :scheme),
      Keyword.get(config, :host),
      path
    ] |> IO.iodata_to_binary
  end
end
