defmodule ExMLS.Enums do
  use EnumType

  # 5.3. Credentials
  defenum(CredentialType) do
    value(Reseved, 0)
    value(Basic, 1)
    value(X509, 2)
  end

  # 6. Message Framing

  defenum(ProtocolVersion) do
    value(Reserved, 0)
    value(MLS10, 1)
  end

  defenum(ContentType) do
    value(Reserved, 0)
    value(Application, 1)
    value(Proposal, 2)
    value(Commit, 3)
  end

  defenum(SenderType) do
    value(Reserved, 0)
    value(Member, 1)
    value(External, 2)
    value(NewMemberProposal, 3)
    value(NewMemberCommit, 4)
  end

  defenum(WireFormat) do
    value(Reserved, 0)
    value(PublicMessage, 1)
    value(PrivateMessage, 2)
    value(Welcome, 3)
    value(GroupInfo, 4)
    value(KeyPackage, 5)
  end

  # 7.2. Leaf Node Contents

  defenum(LeafNodeSource) do
    value(Reserved, 0)
    value(KeyPackage, 1)
    value(Update, 2)
    value(Commit, 3)
  end

  defenum(CipherSuite) do
    value(Reserved, 0)
    value(MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519, 1)
    value(MLS_128_DHKEMP256_AES128GCM_SHA256_P256, 2)
    value(MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519, 3)
    value(MLS_256_DHKEMX448_AES256GCM_SHA512_Ed448, 4)
    value(MLS_256_DHKEMP521_AES256GCM_SHA512_P521, 5)
    value(MLS_256_DHKEMX448_CHACHA20POLY1305_SHA512_Ed448, 6)
    value(MLS_256_DHKEMP384_AES256GCM_SHA384_P384, 7)
  end

  defenum(ExtensionType) do
    value(Reserved, 0)
    value(ApplicationID, 1)
    value(RatchetTree, 2)
    value(RequiredCapabilities, 3)
    value(ExternalPub, 4)
    value(ExternalSenders, 5)
  end

  defenum(ProposalType) do
    value(Reserved, 0)
    value(Add, 1)
    value(Update, 2)
    value(Removed, 3)
    value(PSK, 4)
    value(ReInit, 5)
    value(ExternalInit, 6)
    value(GroupContextExtensions, 7)
  end

  # 7.8. Tree Hashes
  defenum(NodeType) do
    value(Reserved, 0)
    value(Leaf, 1)
    value(Parent, 2)
  end

  # 8.4. Pre-Shared Keys

  defenum(PSKType) do
    value(Reserved, 0)
    value(External, 1)
    value(Resumption, 2)
  end

  defenum(ResumptionPSKUsage) do
    value(Reserved, 0)
    value(Application, 1)
    value(ReInit, 2)
    value(Branch, 3)
  end

  # 12.4. Commit
  defenum(ProposalOrRefType) do
    value(Reserved, 0)
    value(Proposal, 1)
    value(Reference, 2)
  end
end
