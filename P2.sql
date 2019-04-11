set ansi_warnings on;
GO

use master;
GO

if exists (select name from master.dbo.sysdatabases where name = N'uq17')
drop database uq17;
GO

if not exists (select name from master.dbo.sysdatabases where name = N'uq17')
create database uq17;
GO

use uq17;
GO

if object_id (N'dbo.patient', N'U') is not null
drop table dbo.patient;
GO

CREATE TABLE dbo.patient 
(
	pat_id smallint not null identity(1,1),
	pat_ssn int not null check (pat_ssn > 0 and pat_ssn <= 999999999),
	pat_fname varchar(15) not null,
	pat_lname varchar(30) not null,
	pat_street varchar(30) not null,
	pat_city varchar(30) not null,
	pat_state char(2) NOT NULL default 'FL',
	pat_zip int not null check (pat_zip > 0 and pat_zip <=999999999),
	pat_phone bigint not null check (pat_phone > 0 and pat_phone <=9999999999),
	pat_email varchar(100) null,
	pat_dob date not null,
	pat_gender char(1) not null check (pat_gender in('m','f')),
	pat_notes varchar(45) null,
	primary key (pat_id),

	CONSTRAINT ux_pat_ssn unique nonclustered (pat_ssn ASC)
);


if object_id (N'dbo.medication', N'U') is not null
drop table dbo.medication;

CREATE TABLE dbo.medication
(
	med_id smallint not null identity(1,1),
	med_name varchar(100) not null,
	med_price decimal(5,2) not null check (med_price > 0),
	med_shelf_life date not null,
	med_notes varchar(255) null,
	primary key (med_id)
);

if object_id (N'dbo.prescription', N'U') is not null
drop table dbo.prescription;

CREATE TABLE dbo.prescription
(
	pre_id smallint not null identity (1,1),
	pat_id smallint not null,
	med_id smallint not null,
	pre_date date not null,
	pre_dosage varchar(255) not null,
	pre_num_refills varchar(3) not null,
	pre_notes varchar(255) null,
	primary key (pre_id),

	CONSTRAINT ux_pat_id_med_id_pre_date unique nonclustered 
	(pat_id asc, med_id asc, pre_date asc),

	CONSTRAINT fk_prescription_patient
	FOREIGN KEY (pat_id)
	REFERENCES dbo.patient (pat_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,

	CONSTRAINT fk_prescription_medication
	FOREIGN KEY (med_id)
	REFERENCES dbo.medication (med_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE
);


if object_id (N'dbo.treatment', N'U') is not null
drop table dbo.treatment;

CREATE TABLE dbo.treatment 
(
	trt_id smallint not null identity(1,1),
	trt_name varchar(255) not null,
	trt_price decimal(8,2) not null check (trt_price > 0),
	trt_notes varchar(255) null,
	primary key (trt_id)
);

	
if object_id (N'dbo.physician', N'U') is not null
drop table dbo.physician;
GO

CREATE TABLE dbo.physician 
(
	phy_id smallint not null identity(1,1),
	phy_specialty varchar(25) not null,
	phy_fname varchar(15) not null,
	phy_lname varchar(30) not null,
	phy_street varchar(30) not null,
	phy_city varchar(30) not null,
	phy_state char(2) NOT NULL default 'FL',
	phy_zip int not null check (phy_zip > 0 and phy_zip <=999999999),
	phy_phone bigint not null check (phy_phone > 0 and phy_phone <=9999999999),
	phy_fax bigint not null check (phy_fax > 0 and phy_fax <=9999999999),
	phy_email varchar(100) null,
	phy_url varchar(100) null,
	phy_notes varchar(255) null,
	primary key (phy_id)
);


if object_id (N'dbo.patient_treatment', N'U') is not null
drop table dbo.patient_treatment;

CREATE TABLE dbo.patient_treatment
(
	ptr_id smallint not null identity(1,1),
	pat_id smallint not null,
	phy_id smallint not null,
	trt_id smallint not null,
	ptr_date date not null,
	ptr_start time(0) not null,
	ptr_end time(0) not null,
	ptr_results varchar(255) null,
	ptr_notes varchar(255) null,
	primary key (ptr_id),

	CONSTRAINT ux_pat_id_phy_id_trt_id_ptr_date unique nonclustered 
	(pat_id asc, phy_id asc, trt_id asc, ptr_date asc),

	CONSTRAINT fk_patient_treatment_patient
	FOREIGN KEY (pat_id)
	REFERENCES dbo.patient (pat_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,

	CONSTRAINT fk_patient_treatment_physician
	FOREIGN KEY (phy_id)
	REFERENCES dbo.physician (phy_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,

	CONSTRAINT fk_patient_treatment_treatment
	FOREIGN KEY (trt_id)
	REFERENCES dbo.treatment (trt_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE
);


if object_id (N'dbo.administration_lu', N'U') is not null
drop table dbo.administration_lu;

CREATE TABLE dbo.administration_lu
(
	pre_id smallint not null,
	ptr_id smallint not null,
	primary key (pre_id, ptr_id),

	CONSTRAINT fk_administration_lu_prescription
	FOREIGN KEY (pre_id)
	REFERENCES dbo.prescription (pre_id)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,

	CONSTRAINT fk_administration_lu_patient_treatment
	FOREIGN KEY (ptr_id)
	REFERENCES dbo.patient_treatment (ptr_id)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);


SELECT * FROM information_schema.tables;

EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

INSERT INTO dbo.patient
(pat_ssn, pat_fname, pat_lname, pat_street, pat_city, pat_state, pat_zip, pat_phone, pat_email, pat_dob, pat_gender, pat_notes)

VALUES
('123456789', 'Carla', 'Vanderbilt', '5133 3rd Road', 'Lake Worth', 'FL', '334671234', 5674892390, 'csweeney@yahoo.com', '1961-11-26', 'F', NULL),
('590123654', 'Amanda', 'Lindell', '2241 W. Pensacola Street', 'Tallahassee', 'FL', '323041234', 8891981878, 'acc10c@my.fsu.edu', '1981-04-04', 'F', NULL),
('987456321', 'David', 'Stephens', '1293 Banana Code Drive', 'Panama City', 'FL', '323081234', 8499191166, 'mjowett@comcast.net', '1965-05-15', 'M', NULL),
('365214986', 'Chris', 'Thrombough', '987 Learning Drive', 'Tallahassee', 'FL', '323011234', 9791561651, 'landbeck@fsu.edu', '1969-07-25', 'M', NULL),
('326598236', 'Spencer', 'Moore', '787 Tharpe Road', 'Tallahassee', 'FL', '323061234', 8416815497, 'spencer@my.fsu.edu', '1990-08-14', 'M', NULL);


INSERT INTO dbo.medication
(med_name, med_price, med_shelf_life, med_notes)

VALUES
('Abilify', 200.00, '2014-06-23', NULL),
('Aciphex', 125.00, '2014-06-24', NULL),
('Actonel', 250.00, '2014-06-25', NULL),
('Actoplus', 412.00, '2014-06-26', NULL),
('Actos', 89.00, '2014-06-27', NULL),
('Adacel', 66.00, '2014-06-28', NULL),
('Aderall', 69.00, '2014-06-29', NULL),
('Advair Diskus', 45.00, '2014-06-30', NULL),
('Aggrenox', 66.00, '2014-06-21', NULL),
('Aloxi', 145.00, '2014-06-22', NULL);

INSERT INTO dbo.prescription
(pat_id, med_id, pre_dat, pre_dosage, pre_num_refills, pre_notes)

VALUES
(1, 1, '2011-12-23', 'one per day', '1', NULL),
(1, 2, '2011-12-24', 'two per day', '2', NULL),
(2, 3, '2011-12-25', 'one per day', '1', NULL),
(2, 4, '2011-12-26', 'three per day', '2', NULL),
(3, 5, '2011-12-27', 'one per day', '1', NULL),
(3, 6, '2011-12-28', 'two per day', '2', NULL),
(4, 7, '2011-12-29', 'as needed', '1', NULL),
(4, 8, '2011-12-30', 'one per day', '2', NULL),
(5, 9, '2011-12-31', 'three per day', '1', NULL),
(5, 10, '2011-12-22', 'one per day', 'rpn', NULL);

INSERT INTO dbo.physician
(phy_specialty, phy_fname, phy_lname, phy_street, phy_city, phy_state, phy_zip, phy_phone, phy_fax, phy_email, phy_url, phy_notes)

VALUES
('psychiatrist', 'pete', 'roger', '1233 stadium lane', 'orlando', 'FL', '32314', '7418529999', '3213216565', 'peteroger@gmail.com', 'progerpsych.com', NULL),
('psychology', 'patrick', 'ewing', '4728 thomasville rd', 'tallahassee', 'FL', '32310', '4234123412', '3213216565', 'pe@gmail.com', 'pe.com', NULL),
('orthopedics', 'charles', 'barkley', '823 thing rd', 'tallahassee', 'FL', '32304', '4177278183', '3213216565', 'cb@gmail.com', 'cb.com', NULL),
('dental', 'mark', 'jowett', '923 kerry forest', 'tallahassee', 'FL', '32309', '1676272379', '3213216565', 'mj@gmail.com', 'mj.com', NULL),
('general', 'kobe', 'bryant', '892 call street', 'tallahassee', 'FL', '32312', '7865981429', '3213216565', 'kb@gmail.com', 'kb.com', NULL),
('radiology', 'shaq', 'oneal', '722 woodward', 'tallahassee', 'FL', '32312', '6612738731', '3213216565', 'sn@gmail.com', 'sn.com', NULL),
('optomology', 'john', 'smith', '728 gaines st', 'tallahassee', 'FL', '32312', '7643478328', '3213216565', 'js@gmail.com', 'js.com', NULL),
('pediatrics', 'david', 'richardson', '823 bradfordville rd', 'tallahassee', 'FL', '32309', '6757381298', '3213216565', 'dr@gmail.com', 'dr.com', NULL),
('cardiology', 'bob', 'johnson', '741 farnsworth dr', 'tallahassee', 'FL', '32310', '7418529999', '6756883487', 'bj@gmail.com', 'bj.com', NULL),
('pulmonary', 'john', 'jimmy', '152 monroe st', 'tallahassee', 'FL', '32309', '7418529999', '5648727812', 'jj@gmail.com', 'jj.com', NULL);

INSERT INTO dbo.treatment
(trt_name, trt_price, trt_notes)

VALUES
('knee replacement', 2000.00, NULL),
('heart transplant', 120334.00, NULL),
('hip replacement', 4982.00, NULL),
('tonsils removed', 589129.00, NULL),
('skin graft', 5129.00, NULL),
('bullet removal', 90591.00, NULL),
('liver transplant', 8512.00, NULL),
('shoulder surgery', 4821.00, NULL),
('kidney transplant', 16263.00, NULL),
('appendix removal', 88939.00, NULL);

INSERT INTO dbo.patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)

VALUES
(1, 10, 5, '2011-12-23', '07:08:09', '08:12:15', 'success', NULL),
(1, 9, 6, '2011-12-24', '08:08:09', '09:12:15', 'success', NULL),
(2, 8, 7, '2011-12-25', '09:08:09', '10:12:15', 'success', NULL),
(2, 7, 8, '2011-12-26', '10:08:09', '11:12:15', 'success', NULL),
(3, 6, 9, '2011-12-27', '11:08:09', '12:12:15', 'minor complications', NULL),
(3, 5, 10, '2011-12-28', '12:08:09', '13:12:15', 'success', NULL),
(4, 4, 1, '2011-12-29', '13:08:09', '14:12:15', 'success', NULL),
(4, 3, 2, '2011-12-30', '14:08:09', '15:12:15', 'minor complications', NULL),
(5, 2, 3, '2011-12-31', '15:08:09', '16:12:15', 'success', NULL),
(5, 1, 4, '2011-12-22', '16:08:09', '17:12:15', 'success', NULL);

INSERT INTO dbo.administration
(pre_id, ptr_id)

VALUES
(10, 5),
(9, 6),
(8, 7),
(7, 8),
(6, 9),
(5, 10),
(4, 9),
(3, 8),
(2, 7),
(1, 6);

exec sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

select * from dbo.patient;
select * from dbo.medication;
select * from dbo.prescription;
select * from dbo.physician;
select * from dbo.treatment;
select * from dbo.patient_treatment;
select * from dbo.administration_lu;


