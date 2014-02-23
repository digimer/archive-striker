
-- Detect if lsi is used; cat /proc/mdstat and look for anything after: 
--                Has RAID: Personalities : [raid1]
--             Has no RAID: Personalities : 
-- Get device info;   

-- Hardware (lsi) RAID arrays.
CREATE SEQUENCE storage_lsi_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE storage_lsi_seq OWNER TO "alteeve";

CREATE TABLE storage_lsi (
	lsi_id				int		primary key	default(nextval('storage_lsi_seq')),
	lsi_in_use			boolean				not null	default true,
	
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now()
);
ALTER TABLE storage_lsi OWNER TO "alteeve";

-- Devices that are members of lsi arrays
CREATE SEQUENCE storage_lsi_device_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	MINVALUE 0
	CACHE 1;
ALTER TABLE storage_lsi_device_seq OWNER TO "alteeve";

CREATE TABLE storage_lsi_device (
	smd_id				int		primary key	default(nextval('storage_lsi_device_seq')),
	smd_lsi_id			int,
	
	modified_user			int				not null,
	modified_date			timestamp with time zone	not null	default now(),

	FOREIGN KEY(smd_lsi_id) REFERENCES storage_lsi(lsi_id)
);
ALTER TABLE storage_lsi_device OWNER TO "alteeve";

