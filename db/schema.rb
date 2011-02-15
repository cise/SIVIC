# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110129173921) do

  create_table "admissions", :force => true do |t|
    t.string   "type"
    t.integer  "candidate_id"
    t.string   "candidate_type"
    t.string   "email"
    t.integer  "group_id"
    t.string   "group_type"
    t.integer  "role_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "processed_at"
    t.integer  "introducer_id"
    t.string   "introducer_type"
    t.text     "comment"
    t.boolean  "accepted"
    t.integer  "event_id"
  end

  create_table "agenda_dividers", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.datetime "start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "end_time"
  end

  create_table "agenda_entries", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.text     "description"
    t.string   "speakers"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "embedded_video"
    t.text     "video_thumbnail"
    t.integer  "cm_session_id"
    t.text     "uid"
    t.boolean  "cm_streaming",    :default => false
    t.boolean  "cm_recording",    :default => false
  end

  create_table "agenda_record_entries", :force => true do |t|
    t.integer  "agenda_id"
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "record"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agendas", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "event_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "agenda_entry_id"
    t.integer  "version_child_id"
    t.integer  "version_family_id"
  end

  add_index "attachments", ["version_child_id"], :name => "index_attachments_on_version_child_id"
  add_index "attachments", ["version_family_id"], :name => "index_attachments_on_version_family_id"

  create_table "calendar_event_series", :force => true do |t|
    t.integer  "frequency",    :default => 1
    t.string   "period",       :default => "monthly"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "repeat_until"
    t.string   "title"
    t.text     "description"
    t.integer  "object_id"
    t.string   "object_type"
  end

  create_table "calendar_events", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",                  :default => false
    t.integer  "calendar_event_series_id"
    t.string   "object_type"
    t.integer  "object_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "timezone"
    t.string   "gmt_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "place"
    t.boolean  "isabel_event"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "machine_id"
    t.string   "colour",                  :default => ""
    t.string   "repeat"
    t.integer  "at_job"
    t.integer  "parent_id"
    t.boolean  "character"
    t.boolean  "public_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.boolean  "marte_event",             :default => false
    t.boolean  "marte_room"
    t.boolean  "spam",                    :default => false
    t.text     "notes"
    t.text     "location"
    t.text     "other_streaming_url"
    t.string   "permalink"
    t.integer  "cm_event_id"
    t.integer  "vc_mode",                 :default => 0
    t.text     "other_participation_url"
    t.boolean  "web_interface",           :default => false
    t.boolean  "isabel_interface",        :default => false
    t.boolean  "sip_interface",           :default => false
    t.datetime "generate_pdf_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.string   "mailing_list"
  end

  create_table "logos", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.string   "logoable_type"
    t.integer  "logoable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", :force => true do |t|
    t.string  "name",          :limit => 40, :default => "",    :null => false
    t.string  "nickname",      :limit => 40, :default => "",    :null => false
    t.boolean "public_access",               :default => false
  end

  create_table "machines_users", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "machine_id", :null => false
  end

  create_table "mcus", :force => true do |t|
    t.string   "ip_address"
    t.integer  "mcunumber"
    t.string   "model"
    t.string   "trade"
    t.integer  "total_ports"
    t.integer  "shared_ports"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manager",    :default => false
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :default => "", :null => false
    t.integer "timestamp",                  :null => false
    t.string  "salt",       :default => "", :null => false
  end

  create_table "open_id_ownings", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
    t.boolean "local",      :default => false
  end

  create_table "open_id_trusts", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
  end

  create_table "participants", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "attend"
  end

  create_table "performances", :force => true do |t|
    t.integer  "agent_id"
    t.string   "agent_type"
    t.integer  "role_id"
    t.integer  "stage_id"
    t.string   "stage_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",     :default => true
  end

  create_table "permissions", :force => true do |t|
    t.string "action"
    t.string "objective"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "post_attachments", :force => true do |t|
    t.integer "post_id"
    t.integer "attachment_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader_id"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "parent_id"
    t.integer  "event_id"
    t.boolean  "spam",        :default => false
  end

  create_table "private_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "parent_id"
    t.boolean  "checked",             :default => false
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_sender",   :default => false
    t.boolean  "deleted_by_receiver", :default => false
  end

  create_table "profiles", :force => true do |t|
    t.string  "organization"
    t.string  "phone"
    t.string  "mobile"
    t.string  "fax"
    t.string  "address"
    t.string  "city"
    t.string  "zipcode"
    t.string  "province"
    t.string  "country"
    t.integer "user_id"
    t.string  "prefix_key",    :default => ""
    t.text    "description"
    t.string  "url"
    t.string  "skype"
    t.string  "im"
    t.integer "visibility",    :default => 2
    t.string  "full_name"
    t.string  "discipline"
    t.string  "subdiscipline"
    t.string  "grade"
  end

  create_table "requests", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "reservation_id"
    t.text     "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "reservation_type", :default => "public"
    t.string   "vc_service"
    t.string   "country"
    t.integer  "room_id"
    t.boolean  "aggrement"
    t.string   "state"
    t.text     "notes"
    t.integer  "user_id"
    t.integer  "admin_id"
    t.boolean  "allow_invitation"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ports"
    t.integer  "event_id"
    t.string   "reason_rejection"
    t.integer  "space_id"
    t.integer  "cancelled_by"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "country"
    t.string   "city"
    t.text     "location"
    t.string   "room_type"
    t.string   "service_type"
    t.string   "ip_address"
    t.string   "uri"
    t.decimal  "lng",                 :precision => 10, :scale => 8
    t.decimal  "lat",                 :precision => 10, :scale => 8
    t.integer  "user_id"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "certification_level"
    t.string   "department"
    t.string   "phone_number"
    t.string   "capacity"
    t.text     "equipment"
    t.text     "devices"
    t.string   "light_type"
    t.string   "bandwidth"
    t.boolean  "reevaluation"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "singular_agents", :force => true do |t|
    t.string "type"
    t.string "crypted_password", :limit => 40
    t.string "salt",             :limit => 40
  end

  create_table "sites", :force => true do |t|
    t.string   "name",                          :default => "CLARA VideoConferencias"
    t.text     "description"
    t.string   "domain",                        :default => "sivic.redclara.net"
    t.string   "email",                         :default => "vnoc@redclara.net"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ssl",                           :default => false
    t.boolean  "exception_notifications",       :default => false
    t.string   "exception_notifications_email"
    t.text     "signature"
    t.string   "presence_domain",               :default => "sir.dit.upm.es "
    t.string   "chat_group_service_jid",        :default => "events.sir.dit.upm.es"
    t.string   "cm_domain"
  end

  create_table "source_importations", :force => true do |t|
    t.integer  "source_id"
    t.integer  "importation_id"
    t.string   "importation_type"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uri_id"
  end

  create_table "sources", :force => true do |t|
    t.integer  "uri_id"
    t.string   "content_type"
    t.string   "target"
    t.integer  "container_id"
    t.string   "container_type"
    t.datetime "imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "deleted"
    t.boolean  "public",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "permalink"
    t.boolean  "disabled",    :default => false
    t.boolean  "repository",  :default => false
    t.string   "skin",        :default => "default"
    t.string   "country"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",                        :null => false
    t.integer "taggable_id",                   :null => false
    t.string  "taggable_type", :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name",           :default => "", :null => false
    t.integer "container_id"
    t.string  "container_type"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name", "container_id", "container_type"], :name => "index_tags_on_name_and_container_id_and_container_type"

  create_table "uris", :force => true do |t|
    t.string "uri"
  end

  add_index "uris", ["uri"], :name => "index_uris_on_uri"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "superuser",                               :default => false
    t.boolean  "disabled",                                :default => false
    t.string   "reset_password_code",       :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "timezone"
    t.boolean  "expanded_post",                           :default => false
    t.integer  "notification",                            :default => 1
    t.string   "locale"
    t.boolean  "chat_activation",                         :default => false
    t.integer  "space_id"
  end

end
