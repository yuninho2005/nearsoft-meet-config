plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

-- domain mapper options, must at least have domain base set to use the mapper
muc_mapper_domain_base = "stream.busqandote.com";

turncredentials_secret = "N9EmqUKjptJdyKKK";

turncredentials = {
  { type = "stun", host = "stream.busqandote.com", port = "4446" },
  { type = "turn", host = "stream.busqandote.com", port = "4446", transport = "udp" },
  { type = "turns", host = "stream.busqandote.com", port = "443", transport = "tcp" }
};

cross_domain_bosh = false;
consider_bosh_secure = true;

VirtualHost "stream.busqandote.com"
        -- enabled = false -- Remove this line to enable this host
        authentication = "anonymous"
        -- Properties below are modified by jitsi-meet-tokens package config
        -- and authentication above is switched to "token"
        --app_id="example_app_id"
        --app_secret="example_app_secret"
        -- Assign this host a certificate for TLS, otherwise it would use the one
        -- set in the global section (if any).
        -- Note that old-style SSL on port 5223 only supports one certificate, and will always
        -- use the global one.
        ssl = {
                key = "/etc/prosody/certs/stream.busqandote.com.key";
                certificate = "/etc/prosody/certs/stream.busqandote.com.crt";
        }
        speakerstats_component = "speakerstats.stream.busqandote.com"
        conference_duration_component = "conferenceduration.stream.busqandote.com"
        -- we need bosh
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
            "speakerstats";
            "turncredentials";
            "conference_duration";
        }
        c2s_require_encryption = false

Component "conference.stream.busqandote.com" "muc"
    storage = "none"
    modules_enabled = {
        "muc_meeting_id";
        "muc_domain_mapper";
        -- "token_verification";
    }
    admins = { "focus@auth.stream.busqandote.com" }
    muc_room_locking = false
    muc_room_default_public_jids = true
    
-- internal muc component
Component "internal.auth.stream.busqandote.com" "muc"
    storage = "none"
    modules_enabled = {
        "ping";
    }
    admins = { "focus@auth.stream.busqandote.com", "jvb@auth.stream.busqandote.com" }
    muc_room_locking = false
    muc_room_default_public_jids = true
    
VirtualHost "auth.stream.busqandote.com"
    ssl = {
        key = "/etc/prosody/certs/auth.stream.busqandote.com.key";
        certificate = "/etc/prosody/certs/auth.stream.busqandote.com.crt";
    }
    authentication = "internal_plain"

Component "focus.stream.busqandote.com"
    component_secret = "LqRIUYKp"

Component "speakerstats.stream.busqandote.com" "speakerstats_component"
    muc_component = "conference.stream.busqandote.com"

Component "conferenceduration.stream.busqandote.com" "conference_duration_component"
    muc_component = "conference.stream.busqandote.com"

-- for Jibri
VirtualHost "recorder.stream.busqandote.com"
    modules_enabled = {
        "ping";
    }
    authentication = "internal_plain"
    c2s_require_encryption = false