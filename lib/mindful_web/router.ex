defmodule MindfulWeb.Router do
  use MindfulWeb, :router
  use Sentry.PlugCapture

  import MindfulWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MindfulWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MindfulWeb do
    pipe_through :browser

    get "/", PageController, :index
    get("/healthcheck", HealthCheckController, :check)

    get "/services", PageController, :services
    get "/mental-health-urgent-care", PageController, :urgent_care
    get "/virtual-psychiatry-consultation", PageController, :telehealth
    get "/mindfit-group-therapy", PageController, :group_therapy
    get "/individual-therapy", PageController, :individual_therapy
    get "/frequently-asked-questions", PageController, :faqs
    get "/press", PageController, :press
    get "/careers", PageController, :careers
    get "/our-mission", PageController, :mission
    get "/terms", PageController, :terms
    get "/privacy", PageController, :privacy
    get "/privacy-notice", PageController, :privacy_notice
    get "/policies", PageController, :policies
    get "/prescription-policy", PageController, :prescription_policy
    get "/controlled-substance-alternatives", PageController, :alt_substances
    get "/genesight", PageController, :genesight
    get "/payment-options", PageController, :payment_options
    get "/referrals-and-helplines", PageController, :referrals_and_help
    get "/nyc-therapy-referrals", PageController, :nyc_therapy_referrals
    get "/long-island-therapy-referrals", PageController, :long_island_therapy_referrals
    get "/rehabs-and-residential-placements", PageController, :rehabs_and_residential_placements
    get "/appointment-confirmation-page", PageController, :appt_conf
    get "/covid19", PageController, :covid
    get "/premarket", PremarketController, :new
    post "/premarket/create", PremarketController, :create
    get "/substance-use-coaching", PageController, :substance_use

    get "/what-we-treat", TreatController, :what_we_treat
    get "/what-we-treat/adhd", TreatController, :adhd
    get "/what-we-treat/anxiety-treatment", TreatController, :anxiety
    get "/what-we-treat/depression", TreatController, :depression
    get "/what-we-treat/bipolar", TreatController, :bipolar
    get "/what-we-treat/ptsd", TreatController, :ptsd
    get "/what-we-treat/ocd", TreatController, :ocd
    get "/what-we-treat/eating-disorders", TreatController, :eating
    get "/what-we-treat/insomnia", TreatController, :insomnia
    get "/what-we-treat/adolescent-disorders", TreatController, :adolescent
    get "/what-we-treat/paranoia", TreatController, :paranoia
    get "/what-we-treat/grief-and-bereavement", TreatController, :grief

    # redirects from old site
    get "/locations/new-york/psychiatrist-financial-district", PastSiteController, :redirect
    get "/locations/new-york/financial-district-psychiatrist", PastSiteController, :redirect
    get "/locations/new-york/psychiatrist-west-hempstead", PastSiteController, :redirect
    get "/locations/new-york/west-hempstead-psychiatrist", PastSiteController, :redirect
    get "/locations/illinois/psychiatrist-chicago-fulton-market", PastSiteController, :redirect
    get "/locations/new-jersey/psychiatrist-hoboken/", PastSiteController, :redirect
    get "/our-staff", PastSiteController, :redirect
    get "/locations/new-york/melville-psychiatrist", PastSiteController, :redirect
    get "/bipolar-disorder-5-interesting-facts-you-may-not-know", PastSiteController, :redirect
    get "/locations/new-york/psychiatrist-flatiron", PastSiteController, :redirect
    get "/locations/new-york/psychiatrist-brooklyn", PastSiteController, :redirect
    get "/power-of-responsibility-vs-blame", PastSiteController, :redirect
    get "/locations/new-york/white-plains-psychiatrist", PastSiteController, :redirect
    get "/locations/new-york/psychiatrist-white-plains", PastSiteController, :redirect
    get "/locations/new-york/longislandcity-lic-psychiatry", PastSiteController, :redirect
    get "/locations/new-york/queens-lic-psychiatry", PastSiteController, :redirect
    get "/10-ways-to-manage-stress-and-anxiety-in-difficult-times", PastSiteController, :redirect
    get "/our-staff/nicholas-obertis", PastSiteController, :redirect
    get "/our-staff/ram-pardeshi", PastSiteController, :redirect
    get "/our-staff/tishana-griffith", PastSiteController, :redirect
    get "/our-staff/nora-ennab", PastSiteController, :redirect
    get "/our-staff/james-harrington", PastSiteController, :redirect
    get "/locations/new-york/grand-central-psychiatrist", PastSiteController, :redirect
    get "/locations/new-york/psychiatrist-grand-central", PastSiteController, :redirect
    get "/ways-group-therapy-can-make-you-feel-connected", PastSiteController, :redirect
    get "/locations/new-york/hicksville-ny-psychiatrist", PastSiteController, :redirect
    get "/admin", PastSiteController, :redirect
    get "/welcome-chicago", PastSiteController, :redirect
    get "/welcome-new-jersey", PastSiteController, :redirect
    get "/locations/new-york/flatiron", PastSiteController, :redirect
    get "/locations/new-york/flatiron-psychiatrist", PastSiteController, :redirect
    get "/locations/ny", PastSiteController, :redirect
    get "/locations/illinois/chicago-river-north-psychiatry", PastSiteController, :redirect
    get "/locations/illinois/chicago-lincoln-park-psychiatrist", PastSiteController, :redirect
    get "/locations/illinois/psychiatrist-chicago-river-north", PastSiteController, :redirect
    get "/substance-use-counseling", PastSiteController, :redirect

    get "/locations", StateController, :index
    get "/locations/:slug", StateController, :show
    get "/locations/:slug/:o_slug", OfficeController, :show
    get "/providers", ProviderController, :index
    get "/providers/:slug", ProviderController, :show
    get "/blog", PostController, :index
    get "/blog/:slug", PostController, :show
    get "/leadership-team", TeamMemberController, :index

    get "/schedule-appointment-psychiatrist", PageController, :schedule

    get "/dash/pick-state", UserController, :pick_state
    put "/dash/update-state", UserController, :update_state
    get "/dash/please-confirm", UserController, :please_confirm

    # Onboarding flow routes
    live_session :registration do
      live "/registration", OnboardingLive.Registration, :registration
      live "/registration/schedule", OnboardingLive.Schedule, :registration
    end
  end

  scope "/", MindfulWeb do
    get "/sitemap.xml", SitemapController, :index
  end

  if Application.get_env(:mindful, :environment) in [:dev, :test] do
    scope "/", MindfulWeb do
      pipe_through :browser

      get "/deleted-no-show-data", PageController, :deleted_no_show_ins
    end

    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  ## Authentication routes

  scope "/", MindfulWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    get "/users/register/:state_abbr", UserRegistrationController, :new
    post "/users/state-register", UserRegistrationController, :new_w_state
    post "/users/register", UserRegistrationController, :create
    get "/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", MindfulWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    get "/dash", UserController, :dash
    get "/dash/billing", UserController, :billing
    post "/dash/billing/add-card", UserController, :add_card
    put "/dash/billing/remove-card", UserController, :remove_card
    put "/dash/update-profile", UserController, :update_profile
    put "/dash/update-profile/remove-pic", UserController, :remove_profile_pic
    get "/dash/insurance", UserController, :insurance
    post "/dash/update_insurance_details", UserController, :update_insurance_details
  end

  scope "/admin", MindfulWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin_user]

    get "/dash", AdminController, :index
    live "/new-charge", AdminBillingLive.NewCharge, :new_charge
    live_dashboard "/app-performance-dashboard", metrics: MindfulWeb.Telemetry

    # state routes
    get "/locations/states/new", StateController, :new
    get "/locations/states/:slug/edit", StateController, :edit
    post "/locations/states/create-state", StateController, :create
    put "/locations/states/:slug/update-state", StateController, :update
    delete "/locations/states/:slug/delete-state", StateController, :delete

    # office routes
    get "/locations/states/:slug/offices/new", OfficeController, :new
    get "/locations/states/:slug/offices/:o_slug/edit", OfficeController, :edit
    post "/locations/states/:slug/offices/create-office", OfficeController, :create
    put "/locations/states/:slug/offices/:o_slug/update-office", OfficeController, :update
    delete "/locations/states/:slug/offices/:o_slug/delete-office", OfficeController, :delete

    # manage office providers routes
    live "/locations/states/:slug/offices/:o_slug/manage-providers",
         OfficeLive.ManageProviders,
         :manage_providers

    # office markdown blob routes
    get "/locations/states/:slug/offices/:o_slug/md/new", OfficeController, :new_markdown
    get "/locations/states/:slug/offices/:o_slug/md/edit", OfficeController, :edit_markdown
    post "/locations/states/:slug/offices/:o_slug/create-md", OfficeController, :create_markdown
    put "/locations/states/:slug/offices/:o_slug/update-md", OfficeController, :update_markdown
    delete "/locations/states/:slug/offices/:o_slug/delete-md", OfficeController, :delete_markdown

    # provider routes
    get "/providers/new", ProviderController, :new
    get "/providers/:slug/edit", ProviderController, :edit
    get "/providers/:slug/edit-details", ProviderController, :edit_details
    post "/providers/create-provider", ProviderController, :create
    put "/providers/:slug/update-provider", ProviderController, :update
    put "/providers/:slug/update-provider-details", ProviderController, :update_details
    delete "/providers/:slug/delete-provider", ProviderController, :delete

    # blog routes
    get "/blog/new", PostController, :new
    get "/blog/:slug/edit", PostController, :edit
    post "/blog/create-post", PostController, :create
    put "/blog/:slug/update-post", PostController, :update
    delete "/blog/:slug/delete-post", PostController, :delete
    get "/blog/edit", PostController, :edit_index

    # google reviews auth routes
    get "/dash/new-reviews/:access_token", AdminController, :new_reviews
    get "/dash/new-reviews", AdminController, :new_reviews
    get "/dash/google-reviews", AdminController, :google_reviews

    # team member routes
    get "/dash/team-members/new", TeamMemberController, :new
    get "/dash/team-members/:id/edit", TeamMemberController, :edit
    post "/dash/team-members/create-team-member", TeamMemberController, :create
    put "/dash/team-members/:id/update-team-member", TeamMemberController, :update
    delete "/dash/team-members/:id/delete-team-member", TeamMemberController, :delete

    # user pverify data routes
    get "/user-pverify-data", UserPverifyDataController, :index
    get "/user-pverify-data/:id/edit", UserPverifyDataController, :edit
    put "/user-pverify-data/:id/update", UserPverifyDataController, :update
  end

  scope "/", MindfulWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/webhooks", MindfulWeb do
    pipe_through :api
    post "/stripe/:state", API.StripeController, :index
    post "/helpscout", API.HelpScoutController, :index

    get "/drchrono", API.DrchronoController, :verify
    post "/drchrono", API.DrchronoController, :index
  end
end
