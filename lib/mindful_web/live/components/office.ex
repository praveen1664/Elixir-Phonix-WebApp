defmodule Mindful.Live.Components.Office do
  @moduledoc false
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def card(assigns) do
    ~H"""
    <div phx-click={JS.push("select_office", value: %{office_id: @office.id})} id={"office-#{@office.id}"} class="p-4 text-gray-400 border-gray-200 shadow-md rounded-md cursor-pointer hover:bg-gray-200 gap-x-4">
      <div class="flex items-center">
        <div {[class: "inline-block w-5 h-5 bg-indigo-600 rounded-full border-2 border-white mr-3"]}></div>
        <h3 class="font-bold text-gray-900"><%= @office.name %></h3>
      </div>
      <div class="text-sm mt-2">
        <p class="text-2"><%= full_address(@office) %></p>
        <p class="text-2"><%= "#{@office.city}, #{@office.zip}" %></p>
      </div>
    </div>
    """
  end

  defp full_address(office), do: "#{office.street}, #{office.suite}"
end
