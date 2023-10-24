defmodule ExMLS.Structs do
  use TypedStruct

  # 5.1.2. Signing
  typedstruct(module: SignContent, enforce: true) do
    field(:label, binary())
    field(:content, binary())
  end

  # 5.1.3. Public Key Encryption
  typedstruct(module: EncryptContext, enforce: true) do
    field(:label, binary())
    field(:context, binary())
  end

  # 5.2. Hash-Based Identifiers
  typedstruct(module: RefHashInput, enforce: true) do
    field(:label, binary())
    field(:value, binary())
  end

  # 5.3. Credentials

  typedstruct(module: Certificate, enforce: true) do
    field(:cert_data, binary())
  end

  typedstruct(module: Credential) do
    field(:credential_type, ExMLS.Enums.CredentialType.t(), enforce: true)
    field(:identity, binary())
    field(:certificates, [ExMLS.Structs.Certificate.t()])
  end

  # 6. Message Framing

  typedstruct(module: Sender) do
    field(:sender_type, ExMLS.Enums.SenderType.t(), enforce: true)

    field(:leaf_index, non_neg_integer())
    field(:sender_index, non_neg_integer())
  end

  typedstruct(module: FramedContent, enforce: true) do
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:sender, ExMLS.Structs.Sender.t())
    field(:authenticated_data, binary())

    field(:application_data, binary())
    field(:proposal, ExMLS.Structs.Proposal.t())
    field(:commit, ExMLS.Structs.Commit.t())
  end

  typedstruct(module: MLSMessage) do
    field(:version, ExMLS.Enums.ProtocolVersion.t(), default: ExMLS.Enums.ProtocolVersion.MLS10)
    field(:wire_format, ExMLS.Enums.WireFormat.t(), enforce: true)

    field(:public_message, ExMLS.Structs.PublicMessage.t())
    field(:private_message, ExMLS.Structs.PrivateMessage.t())
    field(:welcome, ExMLS.Structs.Welcome.t())
    field(:group_info, ExMLS.Structs.GroupInfo.t())
    field(:key_package, ExMLS.Structs.KeyPackage.t())
  end

  typedstruct(module: AuthenticatedContent, enforce: true) do
    field(:wire_format, ExMLS.Enums.WireFormat.t())
    field(:content, ExMLS.Structs.FramedContent.t())
    field(:auth, ExMLS.Structs.FramedContentAuthData.t())
  end

  # 6.1. Content Authentication

  typedstruct(module: FramedContentTBS, enforce: true) do
    field(:version, ExMLS.Enums.ProtocolVersion.t(), default: ExMLS.Enums.ProtocolVersion.MLS10)
    field(:wire_format, ExMLS.Enums.WireFormat.t())
    field(:content, ExMLS.Structs.FramedContent.t())

    field(:context, ExMLS.Structs.GroupContext.t(), enforce: false)
  end

  typedstruct(module: FramedContentAuthData) do
    field(:signature, binary(), enforce: true)

    # field(:confirmed_transcript_hash, ExMLS.Opaques.mac())
    field(:confirmation_tag, ExMLS.Opaques.mac())
  end

  # 6.2. Encoding and Decoding a Public Message

  typedstruct(module: PublicMessage, enforce: true) do
    field(:content, ExMLS.Structs.FramedContent.t())
    field(:auth, ExMLS.Structs.FramedContentAuthData.t())

    field(:membership_tag, ExMLS.Opaques.mac(), enforce: false)
  end

  typedstruct(module: AuthenticatedContentTBM, enforce: true) do
    field(:content_tbs, ExMLS.Structs.FramedContentTBS.t())
    field(:auth, ExMLS.Structs.FramedContentAuthData.t())
  end

  # 6.3. Encoding and Decoding a Private Message

  typedstruct(module: PrivateMessage, enforce: true) do
    field(:group_id, binary)
    field(:epoch, non_neg_integer())
    field(:content_type, ExMLS.Enums.ContentType.t())
    field(:authenticated_data, binary())
    field(:sender_data, binary())
    field(:ciphertext, binary())
  end

  # 6.3.1. Content Encryption

  typedstruct(module: PrivateMessageContent) do
    field(:auth, ExMLS.Structs.FramedContentAuthData.t(), enforce: true)

    field(:application_data, binary())
    field(:proposal, ExMLS.Structs.Proposal.t())
    field(:commit, ExMLS.Structs.Commit.t())
  end

  typedstruct(module: PrivateContentAAD, enforce: true) do
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:content_type, ExMLS.Enums.ContentType.t())
    field(:authenticated_data, binary())
  end

  # 6.3.2. Sender Data Encryption

  typedstruct(module: SenderData, enforce: true) do
    field(:leaf_index, non_neg_integer())
    field(:generation, non_neg_integer())
    # TODO length 4?
    field(:reuse_guard, binary())
  end

  typedstruct(module: SenderDataAAD, enforce: true) do
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:content_type, ExMLS.Enums.ContentType.t())
  end

  # 7.1. Parent Node Contents
  typedstruct(module: ParentNode, enforce: true) do
    field(:encryption_key, ExMLS.Opaques.hpke_pk())
    field(:unmerged_leaves, [non_neg_integer()])
  end

  # 7.2. Leaf Node Contents

  typedstruct(module: Capabilities, enforce: true) do
    field(:versions, [ExMLS.Enums.ProtocolVersion.t()])
    field(:cipher_suites, [ExMLS.Enums.CipherSuite.t()])
    field(:extensions, [ExMLS.Enums.ExtensionType.t()])
    field(:proposals, [ExMLS.Enums.ProposalType.t()])
    field(:credentials, [ExMLS.Enums.CredentialType.t()])
  end

  typedstruct(module: Lifetime, enforce: true) do
    field(:not_before, non_neg_integer())
    field(:not_after, non_neg_integer())
  end

  typedstruct(module: Extension, enforce: true) do
    field(:extension_type, ExMLS.Enums.ExtensionType.t())
    field(:extension_data, binary())
  end

  typedstruct(module: LeafNode, enforce: true) do
    field(:encryption_key, ExMLS.Opaques.hpke_pk())
    field(:signature_key, ExMLS.Opaques.signature_pk())
    field(:credential, ExMLS.Structs.Credential.t())
    field(:capabilities, ExMLS.Structs.Capabilities.t())

    field(:leaf_node_source, ExMLS.Enums.LeafNodeSource.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
    field(:signature, binary())

    field(:lifetime, ExMLS.Structs.Lifetime.t(), enforce: false)
    field(:parent_hash, binary(), enforce: false)
  end

  typedstruct(module: LeafNodeTBS, enforce: true) do
    field(:encryption_key, ExMLS.Opaques.hpke_pk())
    field(:signature_key, ExMLS.Opaques.signature_pk())
    field(:credential, ExMLS.Structs.Credential.t())
    field(:capabilities, ExMLS.Structs.Capabilities.t())

    field(:leaf_node_source, ExMLS.Enums.LeafNodeSource.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])

    field(:lifetime, ExMLS.Structs.Lifetime.t(), enforce: false)
    field(:parent_hash, binary(), enforce: false)

    field(:group_id, binary(), enforce: false)
    field(:leaf_index, non_neg_integer(), enforce: false)
  end

  # 7.6. Update Paths

  typedstruct(module: HKPECiphertext, enforce: true) do
    field(:kem_output, binary())
    field(:ciphertext, binary())
  end

  typedstruct(module: UpdatePathNode, enforce: true) do
    field(:encryption_key, ExMLS.Opaques.hpke_pk())
    field(:encrypted_path_secret, [ExMLS.Structs.HKPECiphertext.t()])
  end

  typedstruct(module: UpdatePath, enforce: true) do
    field(:leaf_node, ExMLS.Structs.LeafNode.t())
    field(:nodes, [ExMLS.Structs.UpdatePathNode.t()])
  end

  # 7.8. Tree Hashes

  typedstruct(module: TreeHashInput) do
    field(:node_type, ExMLS.Enums.NodeType.t(), enforce: true)

    field(:leaf_node, ExMLS.Structs.LeafNodeHashInput.t())
    field(:parent_node, ExMLS.Structs.ParentNodeHashInput.t())
  end

  typedstruct(module: LeafNodeHashInput, enforce: true) do
    field(:leaf_index, non_neg_integer())
    field(:leaf_node, ExMLS.Structs.LeafNode.t(), enforce: false)
  end

  typedstruct(module: ParentNodeHashInput, enforce: true) do
    field(:parent_node, ExMLS.Structs.ParentNode.t(), enforce: false)
    field(:left_hash, binary())
    field(:right_hash, binary())
  end

  # 7.9. Parent Hashes
  typedstruct(module: ParentHashInput, enforce: true) do
    field(:encryption_key, ExMLS.Opaques.hpke_pk())
    field(:parent_hash, binary())
    field(:original_sibling_tree_hash, binary())
  end

  # 8. Key Schedule
  typedstruct(module: KDFLabel, enforce: true) do
    field(:length, non_neg_integer())
    field(:label, binary())
    field(:context, binary())
  end

  # 8.1. Group Context
  typedstruct(module: GroupContext, enforce: true) do
    field(:version, ExMLS.Enums.ProtocolVersion.t(), default: ExMLS.Enums.ProtocolVersion.MLS10)
    field(:cipher_suite, ExMLS.Enums.CipherSuite.t())
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:tree_hash, binary())
    field(:confirmed_transcript_hash, binary())
    field(:extensions, [ExMLS.Structs.Extension.t()])
  end

  # 8.2. Transcript Hashes

  typedstruct(module: ConfirmedTranscriptHashInput, enforce: true) do
    field(:wire_format, ExMLS.Enums.WireFormat.t())
    field(:content, ExMLS.Structs.FramedContent.t())
    field(:signature, binary())
  end

  typedstruct(module: InterimTranscriptHashInput, enforce: true) do
    field(:confirmation_tag, ExMLS.Opaques.mac())
  end

  # 8.4. Pre-Shared Keys

  typedstruct(module: PreSharedKeyID) do
    field(:psktype, ExMLS.Enums.PSKType.t(), enforce: true)
    field(:psk_nonce, binary(), enforce: true)

    field(:psk_id, binary())
    field(:usage, ExMLS.Enums.ResumptionPSKUsage.t())
    field(:psk_group_id, binary())
    field(:psk_epoch, non_neg_integer())
  end

  typedstruct(module: PSKLabel, enforce: true) do
    field(:id, ExMLS.Structs.PreSharedKeyID.t())
    field(:index, non_neg_integer())
    field(:count, non_neg_integer())
  end

  # 10. Key Packages

  typedstruct(module: KeyPackage, enforce: true) do
    field(:version, ExMLS.Enums.ProtocolVersion.t())
    field(:cipher_suite, ExMLS.Enums.CipherSuite.t())
    field(:init_key, ExMLS.Opaques.hpke_pk())
    field(:leaf_node, ExMLS.Structs.LeafNode.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
    field(:signature, binary())
  end

  typedstruct(module: KeyPackageTBS, enforce: true) do
    field(:version, ExMLS.Enums.ProtocolVersion.t())
    field(:cipher_suite, ExMLS.Enums.CipherSuite.t())
    field(:init_key, ExMLS.Opaques.hpke_pk())
    field(:leaf_node, ExMLS.Structs.LeafNode.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
  end

  # 11.1. Required Capabilities
  typedstruct(module: RequiredCapabilities, enforce: true) do
    field(:extension_types, [ExMLS.Enums.ExtensionType.t()])
    field(:proposal_types, [ExMLS.Enums.ProposalType.t()])
    field(:credential_types, [ExMLS.Enums.CredentialType.t()])
  end

  # 12.1. Proposals
  typedstruct(module: Proposal) do
    field(:proposal_type, ExMLS.Enums.ProposalType.t(), enforce: true)

    field(:add, ExMLS.Structs.Add.t())
    field(:update, ExMLS.Structs.Update.t())
    field(:remove, ExMLS.Structs.Remove.t())
    field(:psk, ExMLS.Structs.PreSharedKey.t())
    field(:reinit, ExMLS.Structs.ReInit.t())
    field(:external_init, ExMLS.Structs.ExternalInit.t())
    field(:group_context_extensions, ExMLS.Structs.GroupContextExtensions.t())
  end

  # 12.1.1. Add
  typedstruct(module: Add, enforce: true) do
    field(:key_package, ExMLS.Structs.KeyPackage.t())
  end

  # 12.1.2. Update
  typedstruct(module: Update, enforce: true) do
    field(:leaf_node, ExMLS.Structs.LeafNode.t())
  end

  # 12.1.3. Remove
  typedstruct(module: Remove, enforce: true) do
    field(:removed, non_neg_integer())
  end

  # 12.1.4. PreSharedKey
  typedstruct(module: PreSharedKey, enforce: true) do
    field(:psk, ExMLS.Structs.PreSharedKeyID.t())
  end

  # 12.1.5. ReInit
  typedstruct(module: ReInit, enforce: true) do
    field(:group_id, binary())
    field(:version, ExMLS.Enums.ProtocolVersion.t())
    field(:cipher_suite, ExMLS.Enums.CipherSuite.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
  end

  # 12.1.6. ExternalInit
  typedstruct(module: ExternalInit, enforce: true) do
    field(:kem_output, binary())
  end

  # 12.1.7. GroupContextExtensions
  typedstruct(module: GroupContextExtensions, enforce: true) do
    field(:extensions, [ExMLS.Structs.Extension.t()])
  end

  # 12.1.8.1. External Senders Extension
  typedstruct(module: ExternalSender, enforce: true) do
    field(:signature_key, ExMLS.Opaques.signature_pk())
    field(:credential, ExMLS.Structs.Credential.t())
  end

  # 12.4. Commit

  typedstruct(module: ProposalOrRef) do
    field(:type, ExMLS.Enums.ProposalOrRefType.t(), enforce: true)

    field(:proposal, ExMLS.Structs.Proposal.t())
    field(:reference, ExMLS.Opaques.proposal_ref())
  end

  typedstruct(module: Commit, enforce: true) do
    field(:proposals, [ExMLS.Structs.ProposalOrRef.t()])
    field(:path, ExMLS.Structs.UpdatePath.t(), enforce: false)
  end

  # 12.4.3. Adding Members to the Group

  typedstruct(module: GroupInfo, enforce: true) do
    field(:group_context, ExMLS.Structs.GroupContext.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
    field(:confirmation_tag, ExMLS.Opaques.mac())
    field(:signer, non_neg_integer())
    field(:signature, binary())
  end

  typedstruct(module: GroupContextTBS, enforce: true) do
    field(:group_context, ExMLS.Structs.GroupContext.t())
    field(:extensions, [ExMLS.Structs.Extension.t()])
    field(:confirmation_tag, ExMLS.Opaques.mac())
    field(:signer, non_neg_integer())
  end

  # 12.4.3.1. Joining via Welcome Message

  typedstruct(module: PathSecret, enforce: true) do
    field(:path_secret, binary())
  end

  typedstruct(module: GroupSecret, enforce: true) do
    field(:joiner_secret, binary())
    field(:path_secret, ExMLS.Structs.PathSecret.t(), enforce: false)
    field(:psks, [ExMLS.Structs.PreSharedKeyID.t()])
  end

  typedstruct(module: EncryptedGroupSecrets, enforce: true) do
    field(:new_member, ExMLS.Opaques.key_package_ref())
    field(:encrypted_group_secrets, ExMLS.Structs.HKPECiphertext.t())
  end

  typedstruct(module: Welcome, enforce: true) do
    field(:cipher_suite, ExMLS.Enums.CipherSuite.t())
    field(:secrets, [ExMLS.Structs.EncryptedGroupSecrets.t()])
    field(:encrypted_group_info, binary())
  end

  # 12.4.3.2. Joining via External Commits
  typedstruct(module: ExternalPub, enforce: true) do
    field(:external_pub, ExMLS.Opaques.hpke_pk())
  end

  # 12.4.3.3. Ratchet Tree Extension
  typedstruct(module: Node) do
    field(:node_type, ExMLS.Enums.NodeType.t())

    field(:leaf_node, ExMLS.Structs.LeafNode.t())
    field(:parent_node, ExMLS.Structs.ParentNode.t())
  end
end
