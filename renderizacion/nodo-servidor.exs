defmodule NodoServidor do
  @nombre_servicio_local :servicio_render

  def main() do
    IO.puts("SERVIDOR ACTIVADO - Esperando plantillas...")
    Process.register(self(), @nombre_servicio_local)
    escuchar()
  end

  def escuchar() do
    receive do
      {remitente, :fin} ->
        IO.puts("Fin de la transmision.")
        send(remitente, :fin)

      {remitente, plantillas} when is_list(plantillas) ->
        resultado = Enum.map(plantillas, &render/1)
        send(remitente, resultado)
        escuchar()
    end
  end

  def render(%Plantilla{id: id, nombre: template, vars: vars}) do
    html =
      Enum.reduce(vars, template, fn {key, value}, acc ->
        placeholder = "{{#{key}}}"
        String.replace(acc, placeholder, to_string(value))
      end)
    {id, html}
  end
end

NodoServidor.main()
