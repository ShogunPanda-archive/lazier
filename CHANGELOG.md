### 2018-04-22 / 4.2.7


### 4.2.2 / 2016-11-10

* Updated dependencies.

### 4.2.1 / 2016-03-29

* Updated dependencies and linted code.

### 4.2.0 / 2014-11-02

* Added `Lazier::String#ensure_url_with_scheme`.

### 4.1.0 / 2014-10-02

* Added `Lazier.loaded_modules` and `Lazier.modules_loaded?`.

### 4.0.6 / 2014-09-29

* Include fallback mechanism for translations lookup.

### 4.0.5 / 2014-06-19

* Save alias upon timezone finding.

### 4.0.4 / 2014-06-19

* Added `Lazier::Timezone#current_alias=`.

### 4.0.3 / 2014-06-06

* System locale detection fix.

### 4.0.2 / 2014-06-06

* Don't force locales validation.

### 4.0.1 / 2014-06-06

* Dependencies fixes.

### 4.0.0 / 2014-06-01

#### General
* **Dropped compatibility for Ruby < 2.1**.
* All `is_*?` are renamed without the prefix.
* Moved to i18n as I18N backend for `Lazier::I18n`.
* Merged `Lazier::I18n` and `Lazier::Localizer` into a new class `Lazier::I18n`.
* Changed interface for `Lazier#find_class`.
* Changed interface for `Lazier#benchmark`.
* Removed `Lazier.load_hash_method_access`.

#### Lazier::Configuration

* Changed parameters name for `Lazier::Configuration#property`.
 
#### Lazier::Date

* Changed interface for `Lazier::Date.years`.
* Removed `Lazier::Date.timezones`.
* Removed `Lazier::Date.list_timezones`.
* Removed `Lazier::Date.find_timezone`.
* Removed `Lazier::Date.parameterize_zone`.
* Removed `Lazier::Date.unparameterize_zone`.
* Removed `Lazier::Date.rationalize_offset`.
* Removed `Lazier::Date#utc_time`.
* Renamed `Lazier::Date#in_months` to `Lazier::Date.months_since_year`. 
* Merged `Lazier::Date#lstrftime`, `Lazier::Date#local_strftime` and `Lazier::Date#local_lstrftime` to `Lazier::Date#format`.

#### Lazier::Object

* Changed parameters name for `Lazier::Object#ensure_string`. 
* Changed interface for `Lazier::Object#ensure_array`.
* Changed interface for `Lazier::Object#ensure_hash`.
* Changed parameters name for `Lazier::Object#to_integer`.
* Changed parameters name for `Lazier::Object#to_float`.
* Changed interface for `Lazier::Object#format_number`.
* Changed interface for `Lazier::Object#format_boolean`.
* Changed interface for `Lazier::Object#indexize`.
* Renamed `Lazier::Object#numeric?` to `Lazier::Object#number?`.
* Renamed `Lazier::Object#for_debug` to `Lazier::Object#to_debug` and changed its interface.
* Changed interface for `Lazier::Object#ensure_hash`.

#### Lazier::Settings

* Changed interface for `Lazier::Settings#setup_format_number`.
* Changed interface for `Lazier::Settings#setup_date_names`.
* Removed `Lazier::Settings#i18n=`.

#### Lazier::String

* Removed `Lazier::String#untitleize`.
* Removed `Lazier::String#replace_ampersands`.
* Renamed `Lazier::String#split_token` to `Lazier::String#tokenize` and changed its interface.

#### Lazier::Timezone

* Renamed `Lazier::Timezone.list_all` to `Lazier::Timezone.list` and changed its interface.
* Renamed `Lazier::Timezone.parameterize_zone` to `Lazier::Timezone.parameterize`. 
* Renamed `Lazier::Timezone.unparameterize_zone` to `Lazier::Timezone.unparameterize` and changed its interface.
* Changed interface for `Lazier::Timezone#current_offset`.
* Merged `Lazier::Timezone#dst_offset` and `Lazier::Timezone#offset` in `Lazier::Timezone#offset`.
* Merged `Lazier::Timezone#dst_name` in `Lazier::Timezone#name`.
* Merged `Lazier::Timezone.to_str`, `Lazier::Timezone.to_str_with_dst`, `Lazier::Timezone.to_str_parameterized` and 
  `Lazier::Timezone.to_str_with_dst_parameterized` in `Lazier::Timezone.to_str`.

### 3.5.7 / 2014-06-19

* Save alias upon timezone finding.

### 3.5.6 / 2014-06-19

* Added `Lazier::Timezone#current_alias=`.

### 3.5.5 / 2014-04-11

* Bugfix for `Lazier.find_class`.

### 3.5.4 / 2014-04-11

* Dropped support for Ruby < 2.1, even though the code is compatible yet.

### 3.5.3 / 2014-04-10

* Code style fixes.

### 3.5.2 / 2014-04-27

* Added `Lazier::Object#is_number?`.
* Metrics and style fixes.

### 3.5.1 / 2014-02-16

* `Lazier::Hash#ensure_access` now supports multiple accesses.

### 3.5.0 / 2014-02-16

* Added `Lazier::String#split_tokens`.

### 3.4.2 / 2014-01-29

* `Lazier::Object#ensure_array` returns `[]` for `nil` when no default_value is specified.

### 3.4.1 / 2014-01-27

* Fixed return value for `Lazier::Hash#enable_dotted_access`.

### 3.4.0 / 2014-01-25

* Added dotted notation access for Hashes. See: `Lazier::Hash#enable_dotted_access`.
* Added `Lazier::Hash#compact` and `Lazier::Hash#compact!`.
* Added `Lazier::Object#safe_send`.

### 3.3.10 / 2013-12-02

* Fixed boolean conversion.
* Do not load hash method access by default.
