defmodule Mindful.Live.Components.Provider do
  @moduledoc false
  use Phoenix.Component

  alias MindfulWeb.ViewHelpers, as: VH
  alias Phoenix.LiveView.JS

  def card(assigns) do
    ~H"""
    <div phx-click={JS.push("select_provider", value: %{provider_id: @provider.id})} id={"provider-#{@provider.id}"} class="p-4 text-gray-400 border-gray-200 shadow-md rounded-md cursor-pointer hover:bg-gray-200 gap-x-4">
      <div class="flex items-center">
        <%= if @provider.image_path do %>
          <img src={VH.uploaded_img_url(@provider.image_path)} alt={VH.formalize_name(@provider)} class="w-24 h-24 rounded-xl mr-3">
        <% else %>
          <div {[class: "inline-block w-5 h-5 bg-indigo-600 rounded-full border-2 border-white mr-3"]}></div>
        <% end %>
        <div>
          <h3 class="font-bold text-gray-900"><%= VH.formalize_name(@provider) %></h3>
          <div class="text-sm">
            <p class="italic text-gray-600"><%= @provider.job_title %></p>
            <p class="text-xs"><%= VH.truncate(@provider.about, 120) %></p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
