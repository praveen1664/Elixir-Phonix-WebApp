defmodule MindfulWeb.PageController do
  use MindfulWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html",
      page_title: "Mindful Care | Urgent Psychiatry and Mental Health Treatment",
      page_description:
        "Urgent Psychiatry, Therapy, and Medication Management Treatments Covered by Insurance",
      metatags: MindfulWeb.PageView.metatags(:index)
    )
  end

  def services(conn, _params) do
    render(conn, "services.html",
      page_title: "Mental Health Urgent Care in NYC, NJ, and Chicago | Urgent Psychiatric Care",
      page_description:
        "Our services include Urgent Psychiatic Care, Individual Therapy, Group Therapy, and Virtual Psychiatry. We believe in mental health care for all.",
      metatags: MindfulWeb.PageView.metatags(:services)
    )
  end

  def urgent_care(conn, _params) do
    render(conn, "urgent_care.html",
      page_title: "Mental Health Urgent Care in NYC, NJ, and Chicago | Urgent Psychiatric Care",
      page_description:
        "Mental Health Urgent Care covered by insurance. Psychiatry and Therapy treatment made affordable.",
      metatags: MindfulWeb.PageView.metatags(:urgent_care)
    )
  end

  def telehealth(conn, _params) do
    render(conn, "telehealth.html",
      page_title: "Telepsychiatry Virtual Services | Mindful Care | NY NJ and Chicago",
      page_description:
        "Mindful Care now offers virtual telehealth services for mental health psychiatry and therapy. Schedule today!",
      metatags: MindfulWeb.PageView.metatags(:telehealth)
    )
  end

  def group_therapy(conn, _params) do
    render(conn, "group_therapy.html",
      page_title: "Group Therapy | Cognitive Behavioral Therapy | NY, NJ, IL",
      page_description:
        "Guided by experienced therapists, Cognitive Behavioral Therapy (CBT) offers group therapy support and coaching in a dynamic setting.",
      metatags: MindfulWeb.PageView.metatags(:group_therapy)
    )
  end

  def faqs(conn, _params) do
    render(conn, "faqs.html",
      page_title: "Frequently Asked Questions | Mindful Care",
      page_description:
        "Frequently asked questions about Mindful Care's psychiatry and therapy treatments.",
      metatags: MindfulWeb.PageView.metatags(:faqs)
    )
  end

  def press(conn, _params) do
    render(conn, "press.html",
      page_title: "Press | Mindful Care",
      page_description: "Mindful Care Press and News"
    )
  end

  def careers(conn, _params) do
    jobs_by_dept = MindfulWeb.Services.JazzhrCache.fetch_all_jobs()

    render(conn, "careers.html",
      jobs_by_dept: jobs_by_dept,
      page_title: "Careers | Mindful Care",
      page_description:
        "Working at Mindful is a calling; our team members want to work here because they are on the front lines of the mental health crisis."
    )
  end

  def mission(conn, _params) do
    render(conn, "mission.html",
      page_title: "Our Mission | Mindful Care",
      page_description:
        "Mindful Care is all about taking that hard out of the process by making things as easy as possible for patients through a streamlined service with no appointments needed for same-day treatment, and with most insurance plans accepted."
    )
  end

  def terms(conn, _params) do
    render(conn, "terms.html", page_title: "Terms of Use | Mindful Care")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html", page_title: "Privacy Policy | Mindful Care")
  end

  def privacy_notice(conn, _params) do
    render(conn, "privacy_notice.html", page_title: "Notice of Privacy Practices | Mindful Care")
  end

  def policies(conn, _params) do
    render(conn, "policies.html",
      page_title: "Policies and Informed Consent | Mindful Care",
      page_description: "Mindful Care Policies"
    )
  end

  def prescription_policy(conn, _params) do
    render(conn, "prescription_policy.html",
      page_title: "Prescription Policy | Mindful Care",
      page_description: "Mindful Care is commited to prescibing psychiatry medications safely"
    )
  end

  def alt_substances(conn, _params) do
    render(conn, "alt_substances.html",
      page_title: "Controlled Substance Alternatives | Mindful Care",
      page_description:
        "We do not prescribe any habit forming or controlled substances. There are healthy non habit forming alternatives that are available."
    )
  end

  def genesight(conn, _params) do
    render(conn, "genesight.html",
      page_title: "GeneSight Genetic Testing | Mindful Care",
      page_description:
        "GeneSight® is advanced genetic testing for mental health. Mindful Care providers can review the results. Schedule an appointment today."
    )
  end

  def payment_options(conn, _params) do
    render(conn, "payment_options.html",
      page_title: "Insurance and Payment Options | Mindful Care",
      page_description:
        "Mindful Care is in-network with most major insurances and Medicare. We know that understanding your plans mental health benefits can be confusing, we’re here to answer your questions so just give us a call."
    )
  end

  def appt_conf(conn, _params) do
    render(conn, "appt_conf.html", page_title: "Appointment Confirmation Page | Mindful Care")
  end

  def anxiety(conn, _params) do
    render(conn, "anxiety.html",
      page_title: "Anxiety & Panic Treatment NYC Area | Mindful Care",
      page_description:
        "Mindful Care provides anxiety treatment in NY, NJ, and IL. Suffering from Panic Attacks? Get help fast. Learn more here."
    )
  end

  def schedule(conn, params) do
    show_part_2? = is_binary(params["namep1"])

    render(conn, "schedule.html",
      show_part_2?: show_part_2?,
      page_title: "Schedule Appointments | Mindful Care",
      page_description:
        "Mindful Care offers same-day support from licensed psychiatrists. Need help? Click here to learn more and schedule an appointment."
    )
  end

  def referrals_and_help(conn, _params) do
    render(conn, "referrals_and_help.html",
      page_title: "Referrals and Helplines - Mindful Care",
      page_description:
        "If you or someone you know is experiencing a serious illness or a mental health crisis, please call 911 or visit the emergency room nearest to you. Other resources available throughout New York City can be found here."
    )
  end

  def nyc_therapy_referrals(conn, _params) do
    render(conn, "nyc_therapy_referrals.html",
      page_title: "NYC Therapy Referrals - Mindful Care",
      page_description:
        "If you or someone you know is experiencing a serious illness or a mental health crisis, please call 911 or visit the emergency room nearest to you. Other resources available throughout New York City can be found here."
    )
  end

  def long_island_therapy_referrals(conn, _params) do
    render(conn, "long_island_therapy_referrals.html",
      page_title: "Long Island Therapy Referrals - Mindful Care",
      page_description:
        "If you or someone you know is experiencing a serious illness or a mental health crisis, please call 911 or visit the emergency room nearest to you. Other resources available throughout New York City can be found here."
    )
  end

  def rehabs_and_residential_placements(conn, _params) do
    render(conn, "rehabs_and_residential_placements.html",
      page_title: "Rehabs and Residential Placements - Mindful Care",
      page_description:
        "If you or someone you know is experiencing a serious illness or a mental health crisis, please call 911 or visit the emergency room nearest to you. Other resources available throughout New York City can be found here."
    )
  end

  def individual_therapy(conn, _params) do
    render(conn, "individual_therapy.html",
      page_title: "Individual Therapy | Cognitive Behavioral Therapy | NY, NJ, IL",
      page_description:
        "Urgent Individual Therapy - MicroTherapy was designed to meet the needs and realities of today: tech-enabled, time-sensitive, and solution-focused individual therapy",
      metatags: MindfulWeb.PageView.metatags(:individual_therapy)
    )
  end

  def covid(conn, _params) do
    render(conn, "covid.html",
      page_title: "Covid-19 Update | Mindful Care",
      page_description: "Information regarding services impacted by Covid-19."
    )
  end

  def deleted_no_show_ins(conn, _) do
    conn
    |> assign(:page_title, "Deleted No-Show Insurance Line Items | Mindful Care")
    |> assign(:line_items, Mindful.Utilities.list_deleted_chrono_line_items())
    |> render("deleted_no_show_ins.html")
  end

  def substance_use(conn, _params) do
    render(conn, "substance_use.html",
      page_title: "Substance-use Coaching | Mindful Care",
      page_description: "Modern substance-abuse recovery coaching.",
      metatags: MindfulWeb.PageView.metatags(:substance_use)
    )
  end
end
