defmodule ExMLS.State do
  alias ExMLS.Messages.ResumptionPSKUsage
  alias ExMLS.CoreTypes.KeyPackage
  alias ExMLS.CoreTypes.LeafNodeOptions
  alias ExMLS.Messages.Proposal
  alias ExMLS.Crypto.CipherSuite
  alias ExMLS.Messages.ReInit
  alias ExMLS.CoreTypes.ExtensionList
  alias ExMLS.KeySchedule.TranscriptHash
  alias ExMLS.KeySchedule.KeyScheduleEpoch
  alias ExMLS.State.State.CachedProposal
  alias ExMLS.State.State.CachedUpdate
  alias ExMLS.Crypto.SignaturePrivateKey
  alias ExMLS.KeySchedule.GroupKeySource

  use TypedStruct

  typedstruct(module: RosterIndex, enforce: true) do
    field(:value, non_neg_integer())
  end

  typedstruct(module: CommitOptions, enforce: true) do
    field(:extra_proposals, [Proposal.t()], default: [])
    field(:inline_tree, boolean())
    field(:force_path, boolean())
    field(:leaf_node_opts, LeafNodeOptions.t())
  end

  typedstruct(module: MessageOpts, enforce: true) do
    field(:encrypt, boolean(), default: false)
    field(:authenticated_data, binary())
    field(:padding_size, non_neg_integer(), default: 0)
  end

  defmodule State do
    alias ExMLS.State.State.ReInitCommitParams
    alias ExMLS.State.State.RestartCommitParams
    alias ExMLS.State.State.ExternalCommitParams
    alias ExMLS.State.State.NormalCommitParams
    alias ExMLS.Messages.Update
    alias ExMLS.Crypto.HPKEPrivateKey

    def external_join(
          _leaf_secret,
          _sig_priv,
          _key_package,
          _group_info,
          _tree,
          _msg_opts,
          _remove_prior,
          _psks
        ),
        do: TODO

    def new_member_add(_group_id, _epoch, _new_member, _sig_priv), do: TODO

    def add_proposal(_self, _key_package), do: TODO
    def update_proposal(_self, _leaf_priv, _opts), do: TODO
    def remove_proposal_roster(_self, _index), do: TODO
    def remove_proposal_leaf(_self, _removed), do: TODO
    def group_context_extensions_proposal(_self, _exts), do: TODO
    def pre_shared_key_proposal(_self, _external_psk_id), do: TODO
    def pre_shared_key_proposal_group(_self, _group_id, _epoch), do: TODO

    def reinit_proposal(_group_id, _version, _cipher_suite, _extensions), do: TODO

    def add(_self, _key_package, _msg_opts), do: TODO
    def update(_self, _leaf_priv, _opts, _msg_opts), do: TODO
    def remove_roster(_self, _index, _msg_opts), do: TODO
    def remove_leaf(_self, _removed, _msg_opts), do: TODO
    def group_context_extensions(_self, _exts, _msg_opts), do: TODO
    def pre_shared_key(_self, _external_psk_id, _msg_opts), do: TODO
    def pre_shared_key_group(_self, _group_id, _epoch, _msg_opts), do: TODO
    def reinit(_self, _group_id, _version, _cipher_suite, _extensions, _msg_opts), do: TODO

    def commit(_self, _leaf_secret, _opts, _msg_opts), do: TODO

    def handle(_self, _msg), do: TODO
    def handle_cached(_self, _msg, _cached_state), do: TODO

    def add_resumption_psk(_self, _group_id, _epoch, _secret), do: TODO
    def remove_resumption_psk(_self, _group_id, _epoch), do: TODO
    def add_external_psk(_self, _id, _secret), do: TODO
    def remove_external_psk(_self, _id), do: TODO

    def do_export(_self, _label, _context, _size), do: TODO
    def group_info(_self, _inline_tree), do: TODO

    def roster(_self), do: TODO
    def epoch_authenticator(_self), do: TODO

    def protect(_self, _authenticated_data, _pt, _padding_size), do: TODO
    def unprotect(_self, _ct), do: TODO

    def group_context(_self), do: TODO

    def create_branch(
          _self,
          _group_id,
          _enc_priv,
          _sig_priv,
          _leaf_node,
          _extensions,
          _key_packages,
          _leaf_secret,
          _commit_opts
        ),
        do: TODO

    def handle_branch(
          _self,
          _init_priv,
          _enc_priv,
          _sig_priv,
          _key_package,
          _welcome,
          _tree
        ),
        do: TODO

    defmodule Tombstone do
      def create_welcome(
            _self,
            _enc_priv,
            _sig_priv,
            _leaf_node,
            _key_packages,
            _leaf_secret,
            _commit_opts
          ),
          do: TODO

      def handle_welcome(
            _self,
            _init_priv,
            _enc_priv,
            _sig_priv,
            _key_package,
            _welcome,
            _tree
          ),
          do: TODO

      typedstruct(enforce: true) do
        field(:epoch_authenticator, binary())
        field(:reinit, ReInit.t())

        field(:prior_group_id, binary())
        field(:prior_epoch, non_neg_integer())
        field(:resumption_psk, binary())
      end
    end

    def reinit_commit(_self, _leaf_secret, _opts, _msg_opts), do: TODO
    def handle_reinit_commit(_self, _commit), do: TODO

    typedstruct(enforce: true) do
      field(:suite, CipherSuite.t())
      field(:group_id, binary())
      field(:epoch, non_neg_integer())
      field(:tree, TreeKEMPublicKey.t())
      field(:tree_priv, TreeKEMPrivateKey.t())
      field(:transcript_hash, TranscriptHash.t())
      field(:extensions, ExtensionList.t())

      field(:key_schedule, KeyScheduleEpoch.t())
      field(:keys, GroupKeySource.t())

      field(:index, LeafIndex.t())
      field(:identity_priv, SignaturePrivateKey.t())

      field(:external_psks, %{binary() => binary()})

      field(:resumption_psks, %{{binary(), non_neg_integer()} => binary()})

      typedstruct(module: CachedProposal, enforce: true) do
        field(:ref, binary())
        field(:proposal, Proposal.t())
        field(:sender, LeafIndex.t(), enforce: false)
      end

      field(:pending_proposals, [CachedProposal.t()], default: [])

      typedstruct(module: CachedUpdate, enforce: true) do
        field(:update_priv, HPKEPrivateKey.t())
        field(:proposal, Update.t())
      end

      field(:cached_update, CachedUpdate.t(), enforce: false)
    end

    def import_tree(_self, _tree_hash, _external, _extensions), do: TODO
    def validate_tree(_self), do: TODO

    typedstruct(module: NormalCommitParams, enforce: true) do
    end

    typedstruct(module: ExternalCommitParams, enforce: true) do
      field(:joiner_key_package, KeyPackage.t())
      field(:force_init_secret, binary())
    end

    typedstruct(module: RestartCommitParams, enforce: true) do
      field(:allowed_usage, ResumptionPSKUsage.t())
    end

    typedstruct(module: ReInitCommitParams, enforce: true) do
    end

    @type commit_params ::
            NormalCommitParams.t()
            | ExternalCommitParams.t()
            | RestartCommitParams.t()
            | ReInitCommitParams.t()

    def commit(_self, _leaf_secret, _opts, _msg_opts, _params), do: TODO

    def handle(_self, _msg, _cached_state, _expected_params), do: TODO
    def handle_content(_self, _content_auth, _cached_state, _expected_params), do: TODO

    def sign(_self, _sender, _content, _authenticated_data, _encrypt), do: TODO
    def protect(_self, _content_auth, _padding_size), do: TODO
    def protect_full(_self, _content, _msg_opts), do: TODO
    def unprotect_to_content_auth(_self, _msg), do: TODO

    def apply_add(_self, _add), do: TODO
    # def apply_update(_self, _)
  end
end
