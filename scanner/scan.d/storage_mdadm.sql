
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

