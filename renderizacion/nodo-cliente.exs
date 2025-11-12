defmodule NodoCliente do
  @nodo_remoto :nodoservidor@servidor
  @servicioremoto {:servicio_render, @nodo_remoto}
  @nombre_servicio_local :servicio_respuestas

  def main() do
    IO.puts("CLIENTE INICIADO: ")

    Process.register(self(), @nombre_servicio_local)

    case Node.connect(@nodo_remoto) do
      true ->
        IO.puts("Conexion establecida - enviando datos...")
        enviar()

      false ->
        IO.puts("No se pudo conectar con el servidor")
    end
  end

  def enviar() do
    plantillas = [
      %Plantilla{
        id: 1,
        nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!",
        vars: %{nombre: "Alice", edad: 30, ciudad: "Wonderland"}
      },
      %Plantilla{
        id: 2,
        nombre: "Hola {{nombre}}, tengo {{edad}} años. Vivo en {{departamento}}!",
        vars: %{nombre: "Bob", edad: 25, departamento: "Antioquia"}
      },
      %Plantilla{
        id: 3,
        nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!",
        vars: %{nombre: "Diana", edad: 28, ciudad: "Dollland"}
      },
      %Plantilla{
        id: 4,
        nombre: "Hola {{nombre}}, tengo {{edad}} años. Estoy en {{materia}}!",
        vars: %{nombre: "Charlie", edad: 35, materia: "Matemáticas"}
      },
      %Plantilla{
        id: 5,
        nombre: "Hola {{nombre}}, tengo {{edad}} años. Bienvenido a {{ciudad}}!",
        vars: %{nombre: "Eve", edad: 22, ciudad: "Eland"}
      }
    ]

    send(@servicioremoto, {self(), plantillas})
    recibir()
    send(@servicioremoto, {self(), :fin})
  end

  def recibir() do
    receive do
      :fin ->
        IO.puts("Proceso terminado")

      respuesta when is_list(respuesta) ->
        Enum.each(respuesta, fn {id, html} ->
          IO.puts("#{id}: #{html}\n")
        end)

        recibir()
    end
  end
end

NodoCliente.main()
