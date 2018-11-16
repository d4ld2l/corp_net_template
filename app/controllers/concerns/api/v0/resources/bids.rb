module Api::V0::Resources::Bids
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [:service, :bid_stage,
                                     comments: %i[account documents],
                                     matching_user: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                     manager: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                     author: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                     assistant: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                     creator: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                     byod_information: %i[project documents],
                                     representation_allowance: [
                                       information_about_participant: [
                                         :customer, :project,
                                         responsible_participant: [account: [default_legal_unit_employee: [legal_unit_employee_position: :position]]],
                                         non_responsible_participants: [account: [default_legal_unit_employee: [legal_unit_employee_position: :position]]],
                                         not_responsible_counterparties: []
                                       ],
                                       meeting_information: %i[check base64_document]
                                     ],
                                     bonus_information: [
                                       :bonus_reason,
                                       bonus_information_participants: %i[account legal_unit bonus_reason],
                                       bonus_information_approvers: [account: [default_legal_unit_employee: [legal_unit_employee_position: :position]]]
                                     ]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [:service, :bid_stage,
                                       matching_user: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                       manager: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
                                       author: [default_legal_unit_employee: [legal_unit_employee_position: :position]],
      ]
    end

    def json_resource_inclusion
      person_inclusion = {
        only: :id,
        methods: %i[full_name position_name photo]
      }
      @json_resource_inclusion ||= {
        only: %i[id created_at updated_at creator_position manager_position creator_comment],
        include: {
          bid_stage: {
            only: %i[id name code]
          },
          author: person_inclusion,
          manager: person_inclusion,
          matching_user: person_inclusion,
          creator: person_inclusion,
          assistant: person_inclusion,
          legal_unit: {
            only: %i[id name]
          },
          comments: {
            only: %i[id created_at body],
            include: {
              account: {
                only: %i[id],
                methods: [:surname_with_firstname]
              }
            },
            methods: [:documents]
          },
          service: {
            only: %i[id name description]
          },
          representation_allowance: {
            only: [:id],
            methods: [],
            include: {
              information_about_participant: {
                only: [:id],
                include: {
                  responsible_participant: {
                    only: [:id],
                    include: {
                      account: {
                        only: [:id],
                        methods: %i[position_name photo full_name]
                      }
                    }
                  },
                  non_responsible_participants: {
                    only: %i[id position],
                    include: {
                      account: {
                        only: [:id],
                        methods: %i[position_name photo full_name]
                      }
                    }
                  },
                  responsible_counterparty: {
                    only: %i[id name position]
                  },
                  not_responsible_counterparties: {
                    only: %i[id name position]
                  },
                  customer: {
                    only: %i[id name]
                  },
                  project: {
                    only: [:charge_code]
                  }
                }
              },
              meeting_information: {
                only: %i[id starts_at place address aim result amount check document],
                include: {
                  check: {
                    only: %i[id name file created_at]
                  },
                  document: {
                    only: %i[id name file created_at]
                  }
                }
              }
            }
          },
          byod_information: {
            only: %i[id byod_type device_model device_inventory_number compensation_amount],
            include: {
              project: {
                only: %i[id charge_code]
              },
              documents: {
                only: %i[id name file created_at]
              }
            }
          },
          team_building_information: {
              only: %i[id project_id number_of_participants city event_format event_date additional_info approx_cost additional_info],
              include: {
                  project: {
                      only: %i[id charge_code]
                  },
                  team_building_information_accounts: {
                      only: %i[id account_id]
                      # only: %i[id], methods: :full_name
                  },
                  team_building_information_legal_units: {
                      only: :id,
                      include: {
                          legal_unit: {
                            only: %i[id name]
                          }
                      }
                  }
              }
          },
          bonus_information: {
            only: %i[id additional],
            include: {
              bonus_reason: {
                only: %i[id name]
              },
              bonus_information_approvers: {
                only: :id,
                include: {
                  account: {
                    only: [:id],
                    methods: %i[position_name photo full_name]
                  }
                }
              },
              bonus_information_participants: {
                only: %i[id sum period_start period_end charge_code misc],
                include: {
                  account: {
                    only: [:id],
                    methods: %i[position_name photo full_name]
                  },
                  bonus_reason: {
                    only: %i[id name]
                  },
                  include: {
                    legal_unit: {
                      only: %i[id name]
                    }
                  }
                }
              }
            }
          }
        }
      }

    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        only: %i[id created_at],
        include: {
          bid_stage: {
            only: %i[id code name created_at]
          },
          author: {
            methods: %i[full_name position_name photo],
            only: []
          },
          manager: {
            methods: %i[full_name position_name photo],
            only: []
          },
          matching_user: {
            methods: %i[full_name position_name photo],
            only: []
          },
          service: {
            only: %i[id name]
          }
        }
      }
    end
  end
end