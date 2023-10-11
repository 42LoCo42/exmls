defmodule Structs do
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
    field(:credential_type, Enums.CredentialType.t(), enforce: true)
    field(:identity, binary())
    field(:certificates, [Structs.Certificate.t()])
  end

  # 6. Message Framing

  typedstruct(module: Sender) do
    field(:sender_type, Enums.SenderType.t(), enforce: true)

    field(:leaf_index, non_neg_integer())
    field(:sender_index, non_neg_integer())
  end

  typedstruct(module: FramedContent, enforce: true) do
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:sender, Structs.Sender.t())
    field(:authenticated_data, binary())

    field(:application_data, binary())
    field(:proposal, Structs.Proposal.t())
    field(:commit, Structs.Commit.t())
  end

  typedstruct(module: MLSMessage) do
    field(:version, Enums.ProtocolVersion.t(), default: Enums.ProtocolVersion.MLS10)
    field(:wire_format, Enums.WireFormat.t(), enforce: true)

    field(:public_message, Structs.PublicMessage.t())
    field(:private_message, Structs.PrivateMessage.t())
    field(:welcome, Structs.Welcome.t())
    field(:group_info, Structs.GroupInfo.t())
    field(:key_package, Structs.KeyPackage.t())
  end

  typedstruct(module: AuthenticatedContent, enforce: true) do
    field(:wire_format, Enums.WireFormat.t())
    field(:content, Structs.FramedContent.t())
    field(:auth, Structs.FramedContentAuthData.t())
  end

  # 6.1. Content Authentication

  typedstruct(module: FramedContentTBS, enforce: true) do
    field(:version, Enums.ProtocolVersion.t(), default: Enums.ProtocolVersion.MLS10)
    field(:wire_format, Enums.WireFormat.t())
    field(:content, Structs.FramedContent.t())

    field(:context, Structs.GroupContext.t(), enforce: false)
  end

  typedstruct(module: FramedContentAuthData) do
    field(:signature, binary(), enforce: true)

    # field(:confirmed_transcript_hash, Opaques.mac())
    field(:confirmation_tag, Opaques.mac())
  end

  # 6.2. Encoding and Decoding a Public Message

  typedstruct(module: PublicMessage, enforce: true) do
    field(:content, Structs.FramedContent.t())
    field(:auth, Structs.FramedContentAuthData.t())

    field(:membership_tag, Opaques.mac(), enforce: false)
  end

  typedstruct(module: AuthenticatedContentTBM, enforce: true) do
    field(:content_tbs, Structs.FramedContentTBS.t())
    field(:auth, Structs.FramedContentAuthData.t())
  end

  # 6.3. Encoding and Decoding a Private Message

  typedstruct(module: PrivateMessage, enforce: true) do
    field(:group_id, binary)
    field(:epoch, non_neg_integer())
    field(:content_type, Enums.ContentType.t())
    field(:authenticated_data, binary())
    field(:sender_data, binary())
    field(:ciphertext, binary())
  end

  # 6.3.1. Content Encryption

  typedstruct(module: PrivateMessageContent) do
    field(:auth, Structs.FramedContentAuthData.t(), enforce: true)

    field(:application_data, binary())
    field(:proposal, Structs.Proposal.t())
    field(:commit, Structs.Commit.t())
  end

  typedstruct(module: PrivateContentAAD, enforce: true) do
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:content_type, Enums.ContentType.t())
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
    field(:content_type, Enums.ContentType.t())
  end

  # 7.1. Parent Node Contents
  typedstruct(module: ParentNode, enforce: true) do
    field(:encryption_key, Opaques.hpke_pk())
    field(:unmerged_leaves, [non_neg_integer()])
  end

  # 7.2. Leaf Node Contents

  typedstruct(module: Capabilities, enforce: true) do
    field(:versions, [Enums.ProtocolVersion.t()])
    field(:cipher_suites, [Enums.CipherSuite.t()])
    field(:extensions, [Enums.ExtensionType.t()])
    field(:proposals, [Enums.ProposalType.t()])
    field(:credentials, [Enums.CredentialType.t()])
  end

  typedstruct(module: Lifetime, enforce: true) do
    field(:not_before, non_neg_integer())
    field(:not_after, non_neg_integer())
  end

  typedstruct(module: Extension, enforce: true) do
    field(:extension_type, Enums.ExtensionType.t())
    field(:extension_data, binary())
  end

  typedstruct(module: LeafNode, enforce: true) do
    field(:encryption_key, Opaques.hpke_pk())
    field(:signature_key, Opaques.signature_pk())
    field(:credential, Structs.Credential.t())
    field(:capabilities, Structs.Capabilities.t())

    field(:leaf_node_source, Enums.LeafNodeSource.t())
    field(:extensions, [Structs.Extension.t()])
    field(:signature, binary())

    field(:lifetime, Structs.Lifetime.t(), enforce: false)
    field(:parent_hash, binary(), enforce: false)
  end

  typedstruct(module: LeafNodeTBS, enforce: true) do
    field(:encryption_key, Opaques.hpke_pk())
    field(:signature_key, Opaques.signature_pk())
    field(:credential, Structs.Credential.t())
    field(:capabilities, Structs.Capabilities.t())

    field(:leaf_node_source, Enums.LeafNodeSource.t())
    field(:extensions, [Structs.Extension.t()])

    field(:lifetime, Structs.Lifetime.t(), enforce: false)
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
    field(:encryption_key, Opaques.hpke_pk())
    field(:encrypted_path_secret, [Structs.HKPECiphertext.t()])
  end

  typedstruct(module: UpdatePath, enforce: true) do
    field(:leaf_node, Structs.LeafNode.t())
    field(:nodes, [Structs.UpdatePathNode.t()])
  end

  # 7.8. Tree Hashes

  typedstruct(module: TreeHashInput) do
    field(:node_type, Enums.NodeType.t(), enforce: true)

    field(:leaf_node, Structs.LeafNodeHashInput.t())
    field(:parent_node, Structs.ParentNodeHashInput.t())
  end

  typedstruct(module: LeafNodeHashInput, enforce: true) do
    field(:leaf_index, non_neg_integer())
    field(:leaf_node, Structs.LeafNode.t(), enforce: false)
  end

  typedstruct(module: ParentNodeHashInput, enforce: true) do
    field(:parent_node, Structs.ParentNode.t(), enforce: false)
    field(:left_hash, binary())
    field(:right_hash, binary())
  end

  # 7.9. Parent Hashes
  typedstruct(module: ParentHashInput, enforce: true) do
    field(:encryption_key, Opaques.hpke_pk())
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
    field(:version, Enums.ProtocolVersion.t(), default: Enums.ProtocolVersion.MLS10)
    field(:cipher_suite, Enums.CipherSuite.t())
    field(:group_id, binary())
    field(:epoch, non_neg_integer())
    field(:tree_hash, binary())
    field(:confirmed_transcript_hash, binary())
    field(:extensions, [Structs.Extension.t()])
  end

  # 8.2. Transcript Hashes

  typedstruct(module: ConfirmedTranscriptHashInput, enforce: true) do
    field(:wire_format, Enums.WireFormat.t())
    field(:content, Structs.FramedContent.t())
    field(:signature, binary())
  end

  typedstruct(module: InterimTranscriptHashInput, enforce: true) do
    field(:confirmation_tag, Opaques.mac())
  end

  # 8.4. Pre-Shared Keys

  typedstruct(module: PreSharedKeyID) do
    field(:psktype, Enums.PSKType.t(), enforce: true)
    field(:psk_nonce, binary(), enforce: true)

    field(:psk_id, binary())
    field(:usage, Enums.ResumptionPSKUsage.t())
    field(:psk_group_id, binary())
    field(:psk_epoch, non_neg_integer())
  end

  typedstruct(module: PSKLabel, enforce: true) do
    field(:id, Structs.PreSharedKeyID.t())
    field(:index, non_neg_integer())
    field(:count, non_neg_integer())
  end

  # 10. Key Packages

  typedstruct(module: KeyPackage, enforce: true) do
    field(:version, Enums.ProtocolVersion.t())
    field(:cipher_suite, Enums.CipherSuite.t())
    field(:init_key, Opaques.hpke_pk())
    field(:leaf_node, Structs.LeafNode.t())
    field(:extensions, [Structs.Extension.t()])
    field(:signature, binary())
  end

  typedstruct(module: KeyPackageTBS, enforce: true) do
    field(:version, Enums.ProtocolVersion.t())
    field(:cipher_suite, Enums.CipherSuite.t())
    field(:init_key, Opaques.hpke_pk())
    field(:leaf_node, Structs.LeafNode.t())
    field(:extensions, [Structs.Extension.t()])
  end

  # 11.1. Required Capabilities
  typedstruct(module: RequiredCapabilities, enforce: true) do
    field(:extension_types, [Enums.ExtensionType.t()])
    field(:proposal_types, [Enums.ProposalType.t()])
    field(:credential_types, [Enums.CredentialType.t()])
  end

  # 12.1. Proposals
  typedstruct(module: Proposal) do
    field(:proposal_type, Enums.ProposalType.t(), enforce: true)

    field(:add, Structs.Add.t())
    field(:update, Structs.Update.t())
    field(:remove, Structs.Remove.t())
    field(:psk, Structs.PreSharedKey.t())
    field(:reinit, Structs.ReInit.t())
    field(:external_init, Structs.ExternalInit.t())
    field(:group_context_extensions, Structs.GroupContextExtensions.t())
  end

  # 12.1.1. Add
  typedstruct(module: Add, enforce: true) do
    field(:key_package, Structs.KeyPackage.t())
  end

  # 12.1.2. Update
  typedstruct(module: Update, enforce: true) do
    field(:leaf_node, Structs.LeafNode.t())
  end

  # 12.1.3. Remove
  typedstruct(module: Remove, enforce: true) do
    field(:removed, non_neg_integer())
  end

  # 12.1.4. PreSharedKey
  typedstruct(module: PreSharedKey, enforce: true) do
    field(:psk, Structs.PreSharedKeyID.t())
  end

  # 12.1.5. ReInit
  typedstruct(module: ReInit, enforce: true) do
    field(:group_id, binary())
    field(:version, Enums.ProtocolVersion.t())
    field(:cipher_suite, Enums.CipherSuite.t())
    field(:extensions, [Structs.Extension.t()])
  end

  # 12.1.6. ExternalInit
  typedstruct(module: ExternalInit, enforce: true) do
    field(:kem_output, binary())
  end

  # 12.1.7. GroupContextExtensions
  typedstruct(module: GroupContextExtensions, enforce: true) do
    field(:extensions, [Structs.Extension.t()])
  end

  # 12.1.8.1. External Senders Extension
  typedstruct(module: ExternalSender, enforce: true) do
    field(:signature_key, Opaques.signature_pk())
    field(:credential, Structs.Credential.t())
  end

  # 12.4. Commit

  typedstruct(module: ProposalOrRef) do
    field(:type, Enums.ProposalOrRefType.t(), enforce: true)

    field(:proposal, Structs.Proposal.t())
    field(:reference, Opaques.proposal_ref())
  end

  typedstruct(module: Commit, enforce: true) do
    field(:proposals, [Structs.ProposalOrRef.t()])
    field(:path, Structs.UpdatePath.t(), enforce: false)
  end

  # 12.4.3. Adding Members to the Group

  typedstruct(module: GroupInfo, enforce: true) do
    field(:group_context, Structs.GroupContext.t())
    field(:extensions, [Structs.Extension.t()])
    field(:confirmation_tag, Opaques.mac())
    field(:signer, non_neg_integer())
    field(:signature, binary())
  end

  typedstruct(module: GroupContextTBS, enforce: true) do
    field(:group_context, Structs.GroupContext.t())
    field(:extensions, [Structs.Extension.t()])
    field(:confirmation_tag, Opaques.mac())
    field(:signer, non_neg_integer())
  end

  # 12.4.3.1. Joining via Welcome Message

  typedstruct(module: PathSecret, enforce: true) do
    field(:path_secret, binary())
  end

  typedstruct(module: GroupSecret, enforce: true) do
    field(:joiner_secret, binary())
    field(:path_secret, Structs.PathSecret.t(), enforce: false)
    field(:psks, [Structs.PreSharedKeyID.t()])
  end

  typedstruct(module: EncryptedGroupSecrets, enforce: true) do
    field(:new_member, Opaques.key_package_ref())
    field(:encrypted_group_secrets, Structs.HKPECiphertext.t())
  end

  typedstruct(module: Welcome, enforce: true) do
    field(:cipher_suite, Enums.CipherSuite.t())
    field(:secrets, [Structs.EncryptedGroupSecrets.t()])
    field(:encrypted_group_info, binary())
  end

  # 12.4.3.2. Joining via External Commits
  typedstruct(module: ExternalPub, enforce: true) do
    field(:external_pub, Opaques.hpke_pk())
  end

  # 12.4.3.3. Ratchet Tree Extension
  typedstruct(module: Node) do
    field(:node_type, Enums.NodeType.t())

    field(:leaf_node, Structs.LeafNode.t())
    field(:parent_node, Structs.ParentNode.t())
  end
end
