# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mindful.Repo.insert!(%Mindful.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mindful.Clinicians
alias Mindful.Locations
alias Mindful.Locations.State
alias Mindful.Locations.Office

alias Mindful.ChronoSchemas.{
  DrchronoPatient,
  DrchronoDoctor,
  DrchronoAppointment,
  DrchronoOffice,
  DrchronoMedication,
  DrchronoProblem
}

alias Mindful.Repo
import Ecto.Query

drchrono_patients = [
  %{
    uuid: 1,
    first_name: "John",
    last_name: "Doe",
    date_of_birth: ~U[2000-02-25 00:00:00Z],
    primary_care_physician: "Dr. Witten",
    home_phone: "555-555-5555",
    cell_phone: "555-555-5555",
    office_phone: "555-555-5555",
    email: "ptestqwe1@test.com",
    gender: "Male",
    address: "123 Fake St.",
    city: "West Hempstead",
    state: "NY",
    zip_code: "11552",
    doctor: 1,
    copay: 30.0,
    ethnicity: "blank",
    patient_status: "A",
    race: "blank",
    date_of_first_appointment: ~U[2021-08-28 00:00:00Z],
    date_of_last_appointment: ~U[2022-01-25 00:00:00Z],
    referring_source: nil,
    primary_insurance_payer_id: "123",
    primary_insurance_company: "123 Insurance Co",
    primary_insurance_group_name: "Green Group PPO",
    primary_insurance_plan_name: "EPO",
    primary_insurance_is_subscriber_the_patient: true,
    primary_insurance_patient_relationship_to_subscriber: nil,
    primary_insurance_subscriber_state: nil,
    secondary_insurance_payer_id: nil,
    secondary_insurance_company: nil,
    secondary_insurance_group_name: nil,
    secondary_insurance_plan_name: nil,
    secondary_insurance_is_subscriber_the_patient: true,
    secondary_insurance_patient_relationship_to_subscriber: nil,
    secondary_insurance_subscriber_state: nil,
    referring_doctor_first_name: "Cliff",
    referring_doctor_last_name: "Hanger",
    referring_doctor_suffix: "Dr.",
    referring_doctor_npi: "1",
    referring_doctor_email: "doctor@test.com",
    referring_doctor_phone: "444-444-4444"
  },
  %{
    uuid: 2,
    first_name: "Jane",
    last_name: "Doe",
    date_of_birth: ~U[2000-01-25 00:00:00Z],
    primary_care_physician: "Dr. Kitten",
    home_phone: "777-777-7777",
    cell_phone: "777-777-7777",
    office_phone: "777-777-7777",
    email: "ptestqwe2@test.com",
    gender: "Female",
    address: "123 Fake St.",
    city: "West Hempstead",
    state: "NY",
    zip_code: "11552",
    doctor: 1,
    copay: 30.0,
    ethnicity: "blank",
    patient_status: "A",
    race: "blank",
    date_of_first_appointment: ~U[2021-12-29 00:00:00Z],
    date_of_last_appointment: ~U[2022-02-17 00:00:00Z],
    referring_source: nil,
    primary_insurance_payer_id: "456",
    primary_insurance_company: "456 Insurance Co",
    primary_insurance_group_name: "Red Group PPO",
    primary_insurance_plan_name: "EPA",
    primary_insurance_is_subscriber_the_patient: true,
    primary_insurance_patient_relationship_to_subscriber: nil,
    primary_insurance_subscriber_state: nil,
    secondary_insurance_payer_id: nil,
    secondary_insurance_company: nil,
    secondary_insurance_group_name: nil,
    secondary_insurance_plan_name: nil,
    secondary_insurance_is_subscriber_the_patient: true,
    secondary_insurance_patient_relationship_to_subscriber: nil,
    secondary_insurance_subscriber_state: nil,
    referring_doctor_first_name: "Cliff",
    referring_doctor_last_name: "Hanger",
    referring_doctor_suffix: "Dr.",
    referring_doctor_npi: "1",
    referring_doctor_email: "doctor@test.com",
    referring_doctor_phone: "444-444-4444"
  },
  %{
    uuid: 3,
    first_name: "Yvonne",
    last_name: "Tester",
    date_of_birth: ~U[2000-02-25 00:00:00Z],
    primary_care_physician: "Dr. Ritten",
    home_phone: "567-456-4565",
    cell_phone: "456-456-4565",
    office_phone: "456-456-4565",
    email: "ptestqwe3@test.com",
    gender: "Female",
    address: "123 Fake St.",
    city: "Chicago",
    state: "IL",
    zip_code: "60626",
    doctor: 2,
    copay: 20.0,
    ethnicity: "blank",
    patient_status: "A",
    race: "blank",
    date_of_first_appointment: ~U[2022-01-05 00:00:00Z],
    date_of_last_appointment: ~U[2022-02-18 00:00:00Z],
    referring_source: nil,
    primary_insurance_payer_id: "890",
    primary_insurance_company: "890 Insurance Co",
    primary_insurance_group_name: "Teal Group PPO",
    primary_insurance_plan_name: "EPO",
    primary_insurance_is_subscriber_the_patient: true,
    primary_insurance_patient_relationship_to_subscriber: nil,
    primary_insurance_subscriber_state: nil,
    secondary_insurance_payer_id: nil,
    secondary_insurance_company: nil,
    secondary_insurance_group_name: nil,
    secondary_insurance_plan_name: nil,
    secondary_insurance_is_subscriber_the_patient: true,
    secondary_insurance_patient_relationship_to_subscriber: nil,
    secondary_insurance_subscriber_state: nil,
    referring_doctor_first_name: "Cliff",
    referring_doctor_last_name: "Hanger",
    referring_doctor_suffix: "Dr.",
    referring_doctor_npi: "1",
    referring_doctor_email: "doctor@test.com",
    referring_doctor_phone: "444-444-4444"
  },
  %{
    uuid: 4,
    first_name: "Wyatt",
    last_name: "Williams",
    date_of_birth: ~U[1990-05-05 00:00:00Z],
    primary_care_physician: "Dr. Litten",
    home_phone: "789-789-7895",
    cell_phone: "789-789-7895",
    office_phone: "789-789-7895",
    email: "ptestqwe4@test.com",
    gender: "Male",
    address: "123 Fake St.",
    city: "Hoboken",
    state: "NJ",
    zip_code: "07030",
    doctor: 2,
    copay: 25.0,
    ethnicity: "blank",
    patient_status: "A",
    race: "blank",
    date_of_first_appointment: nil,
    date_of_last_appointment: nil,
    referring_source: nil,
    primary_insurance_payer_id: nil,
    primary_insurance_company: nil,
    primary_insurance_group_name: nil,
    primary_insurance_plan_name: nil,
    primary_insurance_is_subscriber_the_patient: true,
    primary_insurance_patient_relationship_to_subscriber: nil,
    primary_insurance_subscriber_state: nil,
    secondary_insurance_payer_id: nil,
    secondary_insurance_company: nil,
    secondary_insurance_group_name: nil,
    secondary_insurance_plan_name: nil,
    secondary_insurance_is_subscriber_the_patient: true,
    secondary_insurance_patient_relationship_to_subscriber: nil,
    secondary_insurance_subscriber_state: nil,
    referring_doctor_first_name: nil,
    referring_doctor_last_name: nil,
    referring_doctor_suffix: nil,
    referring_doctor_npi: nil,
    referring_doctor_email: nil,
    referring_doctor_phone: nil
  },
  %{
    uuid: 5,
    first_name: "Gwen",
    last_name: "Hansen",
    date_of_birth: ~U[1976-02-25 00:00:00Z],
    primary_care_physician: "Dr. Bitten",
    home_phone: "345-345-3455",
    cell_phone: "345-345-3455",
    office_phone: "345-345-3455",
    email: "ptestqwe5@test.com",
    gender: "Female",
    address: "123 Fake St.",
    city: "West Hempstead",
    state: "NY",
    zip_code: "11552",
    doctor: 1,
    copay: nil,
    ethnicity: "blank",
    patient_status: "A",
    race: "blank",
    date_of_first_appointment: ~U[2019-03-05 00:00:00Z],
    date_of_last_appointment: ~U[2022-02-10 00:00:00Z],
    referring_source: nil,
    primary_insurance_payer_id: "123",
    primary_insurance_company: "123 Insurance Co",
    primary_insurance_group_name: "Green Group PPO",
    primary_insurance_plan_name: "EPO",
    primary_insurance_is_subscriber_the_patient: true,
    primary_insurance_patient_relationship_to_subscriber: nil,
    primary_insurance_subscriber_state: nil,
    secondary_insurance_payer_id: nil,
    secondary_insurance_company: nil,
    secondary_insurance_group_name: nil,
    secondary_insurance_plan_name: nil,
    secondary_insurance_is_subscriber_the_patient: true,
    secondary_insurance_patient_relationship_to_subscriber: nil,
    secondary_insurance_subscriber_state: nil,
    referring_doctor_first_name: "Cliff",
    referring_doctor_last_name: "Hanger",
    referring_doctor_suffix: "Dr.",
    referring_doctor_npi: "1",
    referring_doctor_email: "doctor@test.com",
    referring_doctor_phone: "444-444-4444"
  }
]

drchrono_doctors = [
  %{
    uuid: 1,
    first_name: "George",
    last_name: "Harrington",
    job_title: "Provider/Staff (Private Practice)",
    specialty: "Physician Assistant",
    office_phone: "345-345-3455",
    profile_picture: nil,
    suffix: "Dr.",
    timezone: "Eastern Time (US & Canada)"
  },
  %{
    uuid: 2,
    first_name: "Beth",
    last_name: "Rice",
    job_title: "Provider/Staff (Private Practice)",
    specialty: "Physician Assistant",
    office_phone: "345-345-3455",
    profile_picture: nil,
    suffix: "Dr.",
    timezone: "Eastern Time (US & Canada)"
  }
]

drchrono_appointments = [
  %{
    uuid: 1,
    duration: 40,
    scheduled_time: ~U[2021-08-28 12:05:00Z],
    created_at: ~U[2021-07-28 12:05:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 1,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 2,
    duration: 40,
    scheduled_time: ~U[2022-01-25 05:20:00Z],
    created_at: ~U[2022-01-20 05:20:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Weeks 1-12",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 1,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 3,
    duration: 40,
    scheduled_time: ~U[2022-03-25 10:20:00Z],
    created_at: ~U[2022-02-20 12:05:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Weeks 1-12",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 1,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 4,
    duration: 40,
    scheduled_time: ~U[2021-12-29 10:00:00Z],
    created_at: ~U[2021-11-29 00:00:00Z],
    doctor: 2,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 2,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 5,
    duration: 40,
    scheduled_time: ~U[2022-02-17 09:00:00Z],
    created_at: ~U[2022-02-10 11:00:00Z],
    doctor: 2,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 2,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 6,
    duration: 40,
    scheduled_time: ~U[2022-02-28 07:00:00Z],
    created_at: ~U[2022-02-24 09:00:00Z],
    doctor: 2,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 2,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 7,
    duration: 40,
    scheduled_time: ~U[2022-01-05 11:00:00Z],
    created_at: ~U[2022-01-01 12:05:00Z],
    doctor: 1,
    office: 2,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 3,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 8,
    duration: 40,
    scheduled_time: ~U[2022-02-18 10:00:00Z],
    created_at: ~U[2022-02-10 12:05:00Z],
    doctor: 1,
    office: 2,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 3,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 9,
    duration: 40,
    scheduled_time: ~U[2019-03-05 10:00:00Z],
    created_at: ~U[2019-03-01 00:00:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 5,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 10,
    duration: 40,
    scheduled_time: ~U[2022-02-10 11:00:00Z],
    created_at: ~U[2022-02-05 10:00:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Psychiatric Evaluation",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 5,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  },
  %{
    uuid: 11,
    duration: 40,
    scheduled_time: ~U[2022-04-26 10:20:00Z],
    created_at: ~U[2022-02-21 12:05:00Z],
    doctor: 1,
    office: 1,
    exam_room: nil,
    profile: nil,
    reason: "Weeks 1-12",
    status: "Complete",
    clinical_note_locked: nil,
    clinical_note_pdf: nil,
    clinical_note_updated_at: nil,
    patient: 1,
    appt_is_break: false,
    recurring_appointment: false,
    base_recurring_appointment: nil,
    is_virtual_base: nil,
    is_walk_in: nil,
    allow_overlapping: nil
  }
]

drchrono_offices = [
  %{
    uuid: 1,
    name: "NY | West Hempstead",
    address: "510 Hempstead Turnpike, Suite 203",
    city: "West Hempstead",
    state: "NY",
    zip_code: "11552",
    start_time: "08:00:00",
    end_time: "21:00:00"
  },
  %{
    uuid: 2,
    name: "IL | Fulton Market",
    address: "159 North Sangamon Street, Floor 2",
    city: "Chicago",
    state: "IL",
    zip_code: "60607",
    start_time: "08:00:00",
    end_time: "19:00:00"
  }
]

drchrono_medications = [
  %{
    uuid: 1,
    doctor: 1,
    patient: 1,
    appointment: nil,
    date_prescribed: ~U[2021-08-29 00:00:00Z],
    date_started_taking: nil,
    date_stopped_taking: nil,
    daw: false,
    dispense_quantity: 30.0,
    dosage_quantity: nil,
    dosage_unit: nil,
    frequency: nil,
    indication: nil,
    name: "Abilify 5 mg oral tablet",
    ndc: "16590074530",
    notes: "Electronically sent by drchrono: 1 each at bedtime",
    number_refills: 0,
    order_status: "Electronic eRx Sent",
    pharmacy_note: "Total dose of 7 mg",
    prn: false,
    route: nil,
    rxnorm: "404602",
    signature_note: "1 each at bedtime",
    status: "active"
  },
  %{
    uuid: 2,
    doctor: 1,
    patient: 1,
    appointment: nil,
    date_prescribed: ~U[2021-09-09 00:00:00Z],
    date_started_taking: nil,
    date_stopped_taking: nil,
    daw: false,
    dispense_quantity: 30.0,
    dosage_quantity: nil,
    dosage_unit: nil,
    frequency: nil,
    indication: nil,
    name: "PROzac 20 mg oral capsule",
    ndc: "16590074530",
    notes: "Electronically sent by drchrono: take 1 daily by mouth",
    number_refills: 0,
    order_status: "Electronic eRx Sent",
    pharmacy_note: nil,
    prn: false,
    route: nil,
    rxnorm: "404602",
    signature_note: "take 1 daily by mouth",
    status: "active"
  }
]

drchrono_problems = [
  %{
    uuid: 1,
    doctor: 1,
    patient: 1,
    date_changed: nil,
    date_diagnosis: ~U[2021-09-09 00:00:00Z],
    date_onset: nil,
    description: "Bipolar disorder, current episode hypomanic",
    icd_code: "",
    info_url: "",
    name: "Bipolar disorder, current episode hypomanic",
    notes: "",
    snomed_ct_code: "31446002",
    status: "active"
  },
  %{
    uuid: 2,
    doctor: 1,
    patient: 1,
    date_changed: nil,
    date_diagnosis: ~U[2021-09-09 00:00:00Z],
    date_onset: nil,
    description: "Generalized anxiety disorder",
    icd_code: "",
    info_url: "",
    name: "Generalized anxiety disorder",
    notes: "",
    snomed_ct_code: "31446002",
    status: "active"
  }
]

# delete previous seed data
Repo.delete_all(from p in DrchronoPatient, where: p.uuid < 100)
Repo.delete_all(from d in DrchronoDoctor, where: d.uuid < 100)
Repo.delete_all(from a in DrchronoAppointment, where: a.uuid < 100)
Repo.delete_all(from o in DrchronoOffice, where: o.uuid < 100)
Repo.delete_all(from m in DrchronoMedication, where: m.uuid < 100)
Repo.delete_all(from prob in DrchronoProblem, where: prob.uuid < 100)

# add static seed data
Repo.insert_all(DrchronoPatient, drchrono_patients)
Repo.insert_all(DrchronoDoctor, drchrono_doctors)
Repo.insert_all(DrchronoAppointment, drchrono_appointments)
Repo.insert_all(DrchronoOffice, drchrono_offices)
Repo.insert_all(DrchronoMedication, drchrono_medications)
Repo.insert_all(DrchronoProblem, drchrono_problems)

### States

il = %{
  abbr: "il",
  coming_soon: false,
  description:
    "Mindful Care in Chicago provides the best in quality psychiatric care to the Windy City! Now open at Fulton Market and Near North Side, our Chicago locations are prepped and ready to help the community.\r\n\r\nFor our Chicago team, our goal is to be the first place in these individual’s minds when they think of quality & supportive care.",
  name: "Illinois",
  image_path: "path",
  available_treatments: ["medical_management"]
}

changeset = State.changeset(%State{}, il)
{:ok, illinois} = Repo.insert(changeset)

ny = %{
  abbr: "ny",
  coming_soon: false,
  description:
    "Mindful Care is a revolutionary medical psychiatry practice in New York. We have locations in New York City, Long Island, and Westchester to help support you.\r\n\r\nWith a focus on patient health, our team of experienced medical providers (Psychiatrist, Psychiatric Physician Assistants, and Psychiatric Nurse Practitioners) is here to help you with your emergency psychiatric needs.",
  name: "New York",
  image_path: "path",
  available_treatments: ["medical_management", "therapy", "substance_use_counseling"]
}

changeset = State.changeset(%State{}, ny)
{:ok, new_york} = Repo.insert(changeset)

nj = %{
  abbr: "nj",
  coming_soon: false,
  description:
    "With new locations in Hoboken and Jersey City, our goal is to help people in New Jersey. We plan on expanding rapidly over the next few years to tackle the mental health crisis in this state. Every day, we help patients overcome various symptoms which impede on their ability to function at their best. We have proven that our treatments work and patients find solace in our immediate care.",
  name: "New Jersey",
  image_path: "path",
  available_treatments: ["medical_management", "therapy", "substance_use_counseling"]
}

changeset = State.changeset(%State{}, nj)
{:ok, new_jersey} = Repo.insert(changeset)

### Offices

ny_offices =
  [
    %{
      name: "Flatiron District",
      description:
        "Located in Flatiron District, Mindful Care provides emergency psychiatric services for anxiety, depression, insomnia, bipolar manic depression.",
      slug: "flatiron-district-psychiatry",
      street: "287 Park Ave S",
      suite: "5th Floor",
      zip: "10010",
      city: "New York",
      state_abbr: new_york.abbr,
      lat: 123.45,
      lng: 124.45
    },
    %{
      name: "Fort Greene",
      description:
        "At Mindful Care Brooklyn, we offer same-day psychiatric care and mental health treatment. We strive to help you gain your life back, starting today, right now.",
      slug: "fort-greene-psychiatry",
      street: "41 Flatbush Ave",
      suite: "2nd Floor",
      zip: "11217",
      city: "New York",
      state_abbr: new_york.abbr,
      lat: 123.45,
      lng: 124.45
    },
    %{
      name: "Grand Central",
      description:
        "Located near the heart of New York City and the connection to the rest of the Northeast, Mindful Care at Grand Central provides exceptional psychiatric and mental health therapy for patients on the go.",
      slug: "grand-cenral-psychiatry",
      street: "230 Park Ave",
      suite: "3rd Floor",
      zip: "10169",
      city: "New York",
      state_abbr: new_york.abbr,
      lat: 123.45,
      lng: 124.45
    }
  ]
  |> Enum.map(&Office.create_changeset(%Office{}, &1))
  |> Enum.map(&Repo.insert/1)
  |> Enum.reduce([], fn {:ok, off}, acc -> [off | acc] end)

nj_offices =
  [
    %{
      name: "Hoboken",
      description:
        "Directly across the Hudson River, Mindful Care’s Hoboken office serves to help Mental Health for New Jersey and New York residents.",
      slug: "hoboken-psychiatry",
      street: "221 River St",
      suite: "9th Floor",
      zip: "07030",
      city: "New Jersey",
      state_abbr: new_jersey.abbr,
      lat: 123.45,
      lng: 124.45
    },
    %{
      name: "Jersey City",
      description:
        "Mindful Care offers same-day psychiatric care and mental health treatment, bringing our affordable, flexible, and revolutionary mental healthcare to Jersey City.",
      slug: "jersey-city-psychiatry",
      street: "2500 Plaza 5",
      suite: "25th Floor",
      zip: "07311",
      city: "New Jersey",
      state_abbr: new_jersey.abbr,
      lat: 123.45,
      lng: 124.45
    }
  ]
  |> Enum.map(&Office.create_changeset(%Office{}, &1))
  |> Enum.map(&Repo.insert/1)
  |> Enum.reduce([], fn {:ok, off}, acc -> [off | acc] end)

il_offices =
  [
    %{
      name: "Fulton Market",
      description:
        "Located in the former warehouse district, Fulton Market, Mindful Care is an industry-changing, revolutionary mental health practice that provides exceptional psychiatry.",
      slug: "fulton-market-psychiatry",
      street: "159 N Sangamon St",
      suite: "Suite 200",
      zip: "60607",
      city: "Chicago",
      state_abbr: illinois.abbr,
      lat: 123.45,
      lng: 124.45
    },
    %{
      name: "Near North Side",
      description:
        "Mindful Care in Chicago provides the best in quality psychiatric care to the Windy City!",
      slug: "near-north-side-psychiatry",
      street: "1500 N Halsted St",
      suite: "2nd Floor",
      zip: "60607",
      city: "Chicago",
      state_abbr: illinois.abbr,
      lat: 123.45,
      lng: 124.45
    }
  ]
  |> Enum.map(&Office.create_changeset(%Office{}, &1))
  |> Enum.map(&Repo.insert/1)
  |> Enum.reduce([], fn {:ok, off}, acc -> [off | acc] end)

### Providers

{:ok, ram_pardeshi} =
  Clinicians.create_provider(%{
    first_name: "Ram",
    last_name: "Pardeshii",
    credential_initials: "MD",
    job_title: "Medical Director and Psychiatrist",
    image_path: "/images/providers/ram-pardeshi170.jpeg",
    about:
      "Ram Pardeshi, MD, is a talented and compassionate psychiatrist. He is the medical director at Mindful Care, a premier psychiatry practice based out of New York. Currently with locations on Long Island and New York City, with plans for expansion, Mindful Care is bridging the gap of waiting times for those who need care, now.",
    slug: "ram",
    rank: 1
  })

{:ok, nora_ennab} =
  Clinicians.create_provider(%{
    first_name: "Nora",
    last_name: "Ennab",
    credential_initials: "PA-C",
    job_title: "Psychiatric Physician Assistant",
    image_path: "/images/providers/noraenna322.jpeg",
    about:
      "Nora Ennab, PA-C, is a certified physician assistant on the team at Mindful Care locations, serving New York City.",
    slug: "nora",
    rank: 3
  })

ny_providers =
  ny_offices
  |> Enum.map(fn office ->
    Enum.map([ram_pardeshi, nora_ennab], fn provider ->
      Locations.assign_office_provider!(office, provider)
    end)
  end)
