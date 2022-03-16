defmodule MindfulWeb.PageView do
  use MindfulWeb, :view

  @doc """
  Creates a map of metatags for the controller action that is passed in as an atom.
  """
  def metatags(:index) do
    %{
      "og:title" => "Mindful Care | Urgent Psychiatry and Mental Health Treatment",
      "og:description" =>
        "Urgent Psychiatry, Therapy, and Medication Management Treatments Covered by Insurance",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Mindful Care | Urgent Psychiatry and Mental Health Treatment",
      "twitter:description" =>
        "Urgent Psychiatry, Therapy, and Medication Management Treatments Covered by Insurance",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:services) do
    %{
      "og:title" => "Mental Health Services at Mindful Care Psychiatry",
      "og:description" =>
        "Our services include Urgent Psychiatic Care, Individual Therapy, Group Therapy, and Virtual Psychiatry. We believe in mental health care for all.",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Mental Health Services at Mindful Care Psychiatry",
      "twitter:description" =>
        "Our services include Urgent Psychiatic Care, Individual Therapy, Group Therapy, and Virtual Psychiatry. We believe in mental health care for all.",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:urgent_care) do
    %{
      "og:title" => "Mental Health Urgent Care in NYC, NJ, and Chicago | Urgent Psychiatric Care",
      "og:description" =>
        "Mental Health Urgent Care covered by insurance. Psychiatry and Therapy treatment made affordable.",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" =>
        "Mental Health Urgent Care in NYC, NJ, and Chicago | Urgent Psychiatric Care",
      "twitter:description" =>
        "Mental Health Urgent Care covered by insurance. Psychiatry and Therapy treatment made affordable.",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:telehealth) do
    %{
      "og:title" => "Telepsychiatry Virtual Services at Mindful Care",
      "og:description" =>
        "Speak with a psychiatrist using Mindful Care's virtual telehealth service. Schedule today!",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Telepsychiatry Virtual Services at Mindful Care",
      "twitter:description" =>
        "Speak with a psychiatrist using Mindful Care's virtual telehealth service. Schedule today!",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:group_therapy) do
    %{
      "og:title" => "Group Therapy at Mindful Care",
      "og:description" =>
        "Guided by experienced therapists, MindFit Group Therapy offers support and coaching in a dynamic setting.",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Group Therapy at Mindful Care",
      "twitter:description" =>
        "Guided by experienced therapists, MindFit Group Therapy offers support and coaching in a dynamic setting.",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:faqs) do
    %{
      "og:title" => "Frequently Asked Questions | Mindful Care",
      "og:description" =>
        "Frequently asked questions about Mindful Care's psychiatry and therapy treatments.",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Frequently Asked Questions | Mindful Care",
      "twitter:description" =>
        "Frequently asked questions about Mindful Care's psychiatry and therapy treatments.",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:individual_therapy) do
    %{
      "og:title" => "Individual Therapy at Mindful Care",
      "og:description" =>
        "Urgent Individual Therapy - MicroTherapy was designed to meet the needs and realities of today: tech-enabled, time-sensitive, and solution-focused individual therapy",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Individual Therapy at Mindful Care",
      "twitter:description" =>
        "Urgent Individual Therapy - MicroTherapy was designed to meet the needs and realities of today: tech-enabled, time-sensitive, and solution-focused individual therapy",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end

  def metatags(:substance_use) do
    %{
      "og:title" => "Mindful Recovery",
      "og:description" => "Substance-use Coaching",
      "og:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg",
      "og:image:width" => "1200",
      "og:image:height" => "630",
      "twitter:card" => "summary_large_image",
      "twitter:site" => "@mindfulcare",
      "twitter:title" => "Mindful Recovery",
      "twitter:description" => "Substance-use Coaching",
      "twitter:image" => "https://files.mindful.care/images/metatagdefaultpic.jpg"
    }
  end
end
