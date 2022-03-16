defmodule MindfulWeb.TreatController do
  use MindfulWeb, :controller

  def what_we_treat(conn, _params) do
    render(conn, "what_we_treat.html",
      page_title: "What We Treat | Mindful Care",
      page_description:
        "Mindful Care treats a wide variety of mental health areas. We provide psychiatric care for Anxiety, Depression, Addiction, ADHD, Bipolar, PTSD, OCD, and more. Mindful Care offers same-day treatment options for mental health emergencies.",
      metatags: MindfulWeb.TreatView.metatags(:what_we_treat)
    )
  end

  def adhd(conn, _params) do
    render(conn, "adhd.html",
      page_title: "ADHD Treatment | In-Person & Online | Mindful Care",
      page_description:
        "Mindful Care is your choice for ADHD treatment in the NYC, Chicago, and Hoboken area. Learn more about our services and schedule here.",
      metatags: MindfulWeb.TreatView.metatags(:adhd)
    )
  end

  def anxiety(conn, _params) do
    render(conn, "anxiety.html",
      page_title: "Anxiety Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful Care provides anxiety treatment in NY, NJ, and IL. Suffering from Panic Attacks? Get help fast. Learn more here."
    )
  end

  def depression(conn, _params) do
    render(conn, "depression.html",
      page_title: "Depression Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful Care offers sympathetic, effective depression treatment in the NY, NJ & IL. Click here to learn more about how we can help you."
    )
  end

  def bipolar(conn, _params) do
    render(conn, "bipolar.html",
      page_title: "Bipolar Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful Care is the best place to turn for bipolar treatment in the NYC area. Click here to learn more about how we can help."
    )
  end

  def ptsd(conn, _params) do
    render(conn, "ptsd.html",
      page_title: "PTSD Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Get compassionate, dedicated PTSD treatment at Mindful Care. Both in-person and telehealth appointments. Click here to learn more."
    )
  end

  def ocd(conn, _params) do
    render(conn, "ocd.html",
      page_title: "OCD Treatments | Mindful Care",
      page_description:
        "Mindful Care is the best place to turn for caring, supportive OCD treatment in New York, New Jersey, and Illinois."
    )
  end

  def eating(conn, _params) do
    render(conn, "eating.html",
      page_title: "Eating Disorder Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful offers treatments for eating disorders and related diagnoses. Mindful Care provides affordable psychiatric care in NY, NJ, & IL"
    )
  end

  def insomnia(conn, _params) do
    render(conn, "insomnia.html",
      page_title: "Insomnia Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Dealing with chronic sleep issues? Find immediate insomnia treatment at Mindful Care. Click here to book an online appointment."
    )
  end

  def adolescent(conn, _params) do
    render(conn, "adolescent.html",
      page_title: "Adolescent Disorder Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful Care offers psychiatric treatment for Adolescent Disorders. Our team provides expert-level care in NY, NJ, and IL."
    )
  end

  def paranoia(conn, _params) do
    render(conn, "paranoia.html",
      page_title: "Paranoia Treatments | Psychiatry and Therapy | Mindful Care",
      page_description:
        "Mindful Care providers are skilled to diagnose and treat various paranoia diagnoses in NY, NJ, or IL. Schedule your appointment today!"
    )
  end

  def grief(conn, _params) do
    render(conn, "grief.html",
      page_title: "Grief and Bereavement Treatments | Mindful Care",
      page_description:
        "Mindful Care provides affordable same-day psychiatric care for Grief and Bereavement diagnoses in NY, NJ, and IL."
    )
  end
end
