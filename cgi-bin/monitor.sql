--
-- Anvil! Monitor database schema
-- Madison Kelly (mkelly@alteeve.ca).
--
-- Backup with: $ pg_dump anvil_monitor -S postgres --disable-triggers -U "alteeve" > anvil_monitor_yyyy-mm-dd_##.out
--

-- Globals
SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;
CREATE LANGUAGE plpgsql;

-- History schema
CREATE SCHEMA history;
ALTER SCHEMA history OWNER TO "alteeve";

-- History Sequence
CREATE SEQUENCE hist_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE hist_seq OWNER TO "alteeve";


-- User accounts, may not use.
CREATE SEQUENCE user_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE user_seq OWNER TO "alteeve";

CREATE TABLE users (
	user_id				int		primary key	default(nextval('user_seq')),
	user_nickname			text				not null,			-- Login name
	user_real_name			text				not null,			-- Real name
	user_email			text				not null,
	user_password			text,
	user_salt			text,
	user_rand			text,
	user_language			text				not null	default 'en_CA',
	user_skin			text				not null	default 'alteeve',
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now()
);
ALTER TABLE users OWNER TO "alteeve";

CREATE TABLE history.users (
	user_id				int				not null,
	user_nickname			text				not null,
	user_real_name			text				not null,
	user_email			text				not null,
	user_password			text,
	user_salt			text,
	user_rand			text,
	user_language			text				not null	default 'en_CA',
	user_skin			text				not null	default 'alteeve',
	history_id			bigint						default(nextval('hist_seq')),
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now()
);
ALTER TABLE history.users OWNER TO "alteeve";

CREATE FUNCTION history_users() RETURNS "trigger"
	AS $$
	DECLARE
		hist_users RECORD;
	BEGIN
		SELECT INTO hist_users * FROM public.users WHERE user_id=new.user_id;
		INSERT INTO history.users
			(user_id, 
			user_nickname, 
			user_real_name, 
			user_email, 
			user_password, 
			user_salt, 
			user_rand, 
			user_language, 
			user_skin, 
			modified_user)
			VALUES
			(hist_users.user_id, 
			hist_users.user_nickname, 
			hist_users.user_real_name, 
			hist_users.user_email, 
			hist_users.user_password, 
			hist_users.user_salt, 
			hist_users.user_rand, 
			hist_users.user_language, 
			hist_users.user_skin, 
			hist_users.modified_user);
		RETURN NULL;
	END;$$
LANGUAGE plpgsql;
ALTER FUNCTION history_users() OWNER TO "alteeve";
CREATE TRIGGER trigger_users AFTER INSERT OR UPDATE ON "users" FOR EACH ROW EXECUTE PROCEDURE history_users();


-- ------------------------------------------------------------------------ --
-- This is information on this node.                                        --
-- ------------------------------------------------------------------------ --

-- Node information
CREATE SEQUENCE node_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE node_seq OWNER TO "alteeve";

CREATE TABLE node (
	node_id				int		primary key	default(nextval('node_seq')),
	node_name			text				not null,		-- I break the short name off of the FQDN
	node_description		text,
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now()
);
ALTER TABLE node OWNER TO "alteeve";



-- ------------------------------------------------------------------------ --
-- Storage tables                                                           --
-- ------------------------------------------------------------------------ --

-- Detect if mdadm is used; cat /proc/mdstat and look for anything after: 
--                Has RAID: Personalities : [raid1]
--             Has no RAID: Personalities : 
-- Get device info;   mdadm -E /dev/vda1
-- Get array info;    mdadm -D /dev/md0
-- Get basic details; mdadm --detail --scan

-- Software (mdadm) RAID arrays.
CREATE SEQUENCE storage_mdadm_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE storage_mdadm_seq OWNER TO "alteeve";

CREATE TABLE storage_mdadm (
	sm_id				int		primary key	default(nextval('storage_mdadm_seq')),
	sm_in_use			boolean				not null	default true,
	-- From mdadm -D /dev/mdX  (always track the UUID and record this device name change
	sm_md_created			text,
	sm_md_raid_level		text,
	sm_md_uuid			text,									-- delete ':'
	sm_md_device			text,
	sm_md_size			bigint,									-- Store in bytes, provided as both base 2 and 10
	sm_md_state			text,
	sm_md_devices_raid		int,
	sm_md_devices_total		int,
	sm_md_devices_active		int,
	sm_md_devices_working		int,
	sm_md_devices_failed		int,
	sm_md_devices_spare		int,
	
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now()
);
ALTER TABLE storage_mdadm OWNER TO "alteeve";

-- Devices that are members of mdadm arrays
CREATE SEQUENCE storage_mdadm_device_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE storage_mdadm_device_seq OWNER TO "alteeve";

CREATE TABLE storage_mdadm_device (
	smd_id				int		primary key	default(nextval('storage_mdadm_device_seq')),
	smd_sm_id			int,
	-- From mdadm -D /dev/mdX  (always track the UUID and record this device name change
	sm_md_raid_level		text,
	sm_md_uuid			text,									-- delete ':'
	sm_md_device			text,
	sm_md_size			bigint,									-- Store in bytes, provided as both base 2 and 10
	sm_md_state			text,
	sm_md_devices_active		int,
	sm_md_devices_working		int,
	sm_md_devices_failed		int,
	sm_md_devices_spare		int,
	
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now(),

	FOREIGN KEY(smd_sm_id) REFERENCES storage_mdadm(sm_id)
);
ALTER TABLE storage_mdadm_device OWNER TO "alteeve";

