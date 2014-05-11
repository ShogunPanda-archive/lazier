### 3.5.4 / 2014-04-11

* Dropped support for Ruby < 2.1, even though the code is compatible yet.

### 3.5.3 / 2014-04-10

* Code style fixes.

### 3.5.2 / 2014-04-27

* Added `Lazier::Object#is_numeric?`.
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