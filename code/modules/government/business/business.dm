/datum/business
	var/name = "Unnamed Business"
	var/description = "Generic description."

	var/categories = list()	// max 3 categories per business

	var/creation_date

	var/business_uid
	var/suspended = FALSE
	var/suspended_reason = ""

	var/gets_business_tax = TRUE                // no one is safe.

	var/list/blacklisted_employees = list()     // by unique id
	var/list/blacklisted_ckeys = list()		// uses ckeys

	var/datum/business_person/owner

	var/access_password = " "

	var/department = ""	// now links by department id lol

	var/list/business_jobs = list()
	var/list/business_accesses = list()
	var/path = "data/persistent/businesses/"

//////////////////////////

/datum/business/New(title, var/desc, var/pass, var/cat, var/owner_uid, var/owner_name, var/owner_email, var/dept) // Makes a new business
	name = title
	description = desc
	access_password = pass
	categories += cat

	if(dept)
		department = dept

	sanitize_business()
	GLOB.all_businesses += src

	..()

/datum/business/proc/sanitize_business(given_dept_id)
	if(!name)
		name = initial(name)
	if(!business_uid)
		business_uid = "[game_id]-[rand(1111,9999)][pick("A","B","C")]"
	if(!creation_date)
		creation_date = full_game_time()
	if(!access_password)
		access_password = GenerateKey()

	if(given_dept_id)
		department = dept_by_id(given_dept_id)

	if(!department)
		var/datum/department/new_dept = new /datum/department(name, BUSINESS_DEPARTMENT, business_uid, description, d_hasbank = TRUE)
		department = new_dept.id

	if(!blacklisted_employees)
		blacklisted_employees = list()
	if(!blacklisted_ckeys)
		blacklisted_ckeys = list()
	if(!business_jobs)
		business_jobs = list()
	if(!business_accesses)
		business_accesses = list()
	if(!categories)
		categories = list()

	if(isemptylist(categories))
		categories += CAT_RETAIL

	refresh_business_support_list()



