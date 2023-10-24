defmodule ExMLS.Opaques do
  # 5.1.1. Public Keys
  @type hpke_pk :: binary()
  @type signature_pk :: binary()

  # 5.2. Hash-Based Identifiers
  @type hash_ref :: binary()
  @type key_package_ref :: hash_ref()
  @type proposal_ref :: hash_ref()

  # 5.3.3. Uniquely Identifying Clients
  @type application_id :: binary()

  # 6.1. Content Authentication
  @type mac :: binary()
end
