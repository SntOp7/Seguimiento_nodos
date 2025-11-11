defmodule Main do
  def enviar(notificacion) do
    case notificacion.canal do
      "push" ->
        :timer.sleep(500)
        IO.puts("Notificación push enviada a #{notificacion.usuario}")
      "email" ->
        :timer.sleep(1000)
        IO.puts("Notificación email enviada a #{notificacion.usuario}")
      "sms" ->
        :timer.sleep(800)
        IO.puts("Notificación SMS enviada a #{notificacion.usuario}")
    end
  end

  def enviar_notificaciones_concurrencia(notificaciones) do
    Enum.map(notificaciones, fn n ->
      Task.async(fn -> enviar(n) end)
    end)
    |> Enum.each(&Task.await/1)
  end

  def enviar_notificaciones_secuencial(notificaciones) do
    Enum.each(notificaciones, fn n -> enviar(n) end)
  end

  def run_benchmark(notificaciones) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :enviar_notificaciones_concurrencia, [notificaciones]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :enviar_notificaciones_secuencial, [notificaciones]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

notificaciones = [
  %Notif{canal: "push", usuario: "usuario1@example.com", plantilla: "plantilla1"},
  %Notif{canal: "email", usuario: "usuario2@example.com", plantilla: "plantilla2"},
  %Notif{canal: "sms", usuario: "usuario3@example.com", plantilla: "plantilla3"}]

Main.enviar_notificaciones_concurrencia(notificaciones)
Main.enviar_notificaciones_secuencial(notificaciones)
Main.run_benchmark(notificaciones)
