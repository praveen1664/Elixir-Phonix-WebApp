defmodule MindfulWeb.TreatView do
  use MindfulWeb, :view

  def metatags(:what_we_treat) do
    %{
      "og:title" => "What We Treat | Mindful Care",
      "og:description" =>
        "Mindful Care treats a wide variety of mental health areas. We provide psychiatric care for Anxiety, Depression, Addiction, ADHD, Bipolar, PTSD, OCD, and more. Mindful Care offers same-day treatment options for mental health emergencies.",
      "og:image" => "",
      "og:image:width" => "",
      "og:image:height" => "",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "What We Treat | Mindful Care",
      "twitter:description" =>
        "Mindful Care treats a wide variety of mental health areas. We provide psychiatric care for Anxiety, Depression, Addiction, ADHD, Bipolar, PTSD, OCD, and more. Mindful Care offers same-day treatment options for mental health emergencies.",
      "twitter:image" => ""
    }
  end

  def metatags(:adhd) do
    %{
      "og:title" => "ADHD Treatment | In-Person & Online | Mindful Care",
      "og:description" =>
        "Mindful Care is your choice for ADHD treatment in the NYC, Chicago, and Hoboken area. Learn more about our services and schedule here.",
      "og:image" => "",
      "og:image:width" => "",
      "og:image:height" => "",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "ADHD Treatment | In-Person & Online | Mindful Care",
      "twitter:description" =>
        "Mindful Care is your choice for ADHD treatment in the NYC, Chicago, and Hoboken area. Learn more about our services and schedule here.",
      "twitter:image" => ""
    }
  end
end
