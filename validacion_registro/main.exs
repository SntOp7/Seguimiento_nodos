defmodule Main do
  def validar_usuarios(usuarios) do
    Enum.map(usuarios, fn user ->
      validar_usuario(user)
    end)
  end

  def validar_usuario_concurrente(usuarios) do
    Enum.map(usuarios, fn user ->
      Task.async(fn -> validar_usuario(user) end)
    end)
    |> Enum.map(&Task.await/1)
  end

  def validar_usuario(%User{email: email, edad: edad, nombre: nombre}) do
    if String.contains?(email, "@") and edad >= 0 and nombre != "" do
      {:ok, nombre}
    else
      {:error, nombre}
    end
  end

  def run_benchmark(usuarios) do
    tiempo_concurrencia = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :validar_usuario_concurrente, [usuarios]})
    IO.puts("Tiempo concurrencia: #{inspect(tiempo_concurrencia)}")
    tiempo_secuencial = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :validar_usuarios, [usuarios]})
    IO.puts("Tiempo secuencial: #{inspect(tiempo_secuencial)}")
    speedup = Benchmark.calcular_speedup(tiempo_concurrencia, tiempo_secuencial)
    IO.puts("Speedup: #{inspect(speedup)}")
  end
end

usuarios = [
  %User{email: "jose@example.com", edad: 30, nombre: "Jose"},
  %User{email: "mariaexample.com", edad: 25, nombre: "Maria"},
  %User{email: "ana@example.com", edad: 28, nombre: "Ana"}
]

Main.validar_usuarios(usuarios)
Main.validar_usuario_concurrente(usuarios)
Main.run_benchmark(usuarios)
