defmodule MindfulWeb.OnboardingLive.RegistrationView do
  use MindfulWeb, :view

  @spec form_title(integer()) :: binary()
  def form_title(1), do: "When do you like to see someone?"
  def form_title(2), do: "Which state do you live in?"
  def form_title(3), do: "What is the reason for your visit?"
  def form_title(4), do: "What is your contact info?"
  def form_title(_invalid_step), do: "Not implemented yet!"

  @spec mark_treatment_as_checked?(list(), binary()) :: boolean()
  def mark_treatment_as_checked?(treatments, _treatment) when not is_list(treatments), do: false
  def mark_treatment_as_checked?(treatments, treatment), do: treatment in treatments

  @spec humanize_field(atom) :: binary
  def humanize_field(field),
    do: field |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()

  @spec disable_treatment_checkbox?(binary(), list()) :: boolean
  def disable_treatment_checkbox?(_treatment, available_treatments)
      when available_treatments == [],
      do: true

  def disable_treatment_checkbox?(treatment, _available_treatments) when treatment == "", do: true

  def disable_treatment_checkbox?(treatment, available_treatments) do
    treatment not in available_treatments
  end
end
