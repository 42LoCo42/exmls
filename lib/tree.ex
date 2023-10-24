defmodule ExMLS.Tree do
  import Bitwise

  @moduledoc ~S"""
  Functions for working with array-based binary trees.
  See [RFC9420 - Appendix C](https://www.rfc-editor.org/rfc/rfc9420#appendix-C).

  Tree used in the function examples:
  ```
             _______07_______
            /                \
        __03__              __11__
       /      \            /      \
     01        05        09        13
    /  \      /  \      /  \      /  \
  00    02  04    06  08    10  12    14
  ```
  """

  @spec level(integer) :: any
  @doc """
  The level of a node in the tree. Leaves are level 0, their parents
  are level 1, etc. If a node's children are at different levels,
  then its level is the max level of its children plus one.

  Examples:
  iex> ExMLS.Tree.level(9)
  1
  """
  def level(x) do
    if x <<< 1 == 0 do
      0
    else
      loop = fn loop, k ->
        if (x >>> k &&& 1) == 1 do
          loop.(loop, k + 1)
        else
          k
        end
      end

      loop.(loop, 0)
    end
  end

  @spec node_width(integer) :: integer
  @doc """
  The number of nodes needed to represent a tree with n leaves.

  Examples:
  iex> ExMLS.Tree.node_width(8)
  15
  """
  def node_width(n) do
    if n == 0 do
      0
    else
      2 * (n - 1) + 1
    end
  end

  @spec root(integer) :: integer
  @doc """
  The index of the root node of a tree with n leaves.

  Examples:
  iex> ExMLS.Tree.root(8)
  7
  """
  def root(n) do
    w = node_width(n)
    (1 <<< trunc(:math.log2(w))) - 1
  end

  @spec left(integer) :: integer
  @doc """
  The left child of an intermediate node.

  Examples:
  iex> ExMLS.Tree.left(9)
  8
  """
  def left(x) do
    k = level(x)

    if k == 0 do
      raise "leaf node has no children"
    end

    Bitwise.bxor(x, 1 <<< (k - 1))
  end

  @spec right(integer) :: integer
  @doc """
  The right child of an intermediate node.

  Examples:
  iex> ExMLS.Tree.right(9)
  10
  """
  def right(x) do
    k = level(x)

    if k == 0 do
      raise "leaf node has no children"
    end

    Bitwise.bxor(x, 3 <<< (k - 1))
  end

  @spec parent(integer, integer) :: integer
  @doc """
  The parent of a node.

  Examples:
  iex> ExMLS.Tree.parent(9, 8)
  11
  """
  def parent(x, n) do
    if x == root(n) do
      raise "root node has no parent("
    end

    k = level(x)
    b = x >>> (k + 1) &&& 1
    Bitwise.bxor(x ||| 1 <<< k, b <<< (k + 1))
  end

  @spec sibling(integer, integer) :: integer
  @doc """
  The other child of the node's parent.

  Examples:
  iex> ExMLS.Tree.sibling(9, 8)
  13
  """
  def sibling(x, n) do
    p = parent(x, n)

    if x < p do
      right(p)
    else
      left(p)
    end
  end

  @spec direct_path(integer, integer) :: list(integer)
  @doc """
  The direct path of a node, ordered from leaf to root.

  Examples:
  iex> ExMLS.Tree.direct_path(9, 8)
  [11, 7]
  """
  def direct_path(x, n) do
    r = root(n)

    if x == r do
      []
    else
      loop = fn loop, d, x ->
        if x != r do
          x = parent(x, n)
          loop.(loop, [x | d], x)
        else
          d
        end
      end

      loop.(loop, [], x)
      # [x | d] up there creates root -> leaf, we want leaf -> root
      |> Enum.reverse()
    end
  end

  @spec copath(integer, integer) :: list(integer)
  @doc """
  The copath of a node, ordered from leaf to root.

  Examples:
  iex> ExMLS.Tree.copath(9, 8)
  [13, 3]
  """
  def copath(x, n) do
    if x == root(n) do
      []
    else
      direct_path(x, n)
      |> List.insert_at(0, x)
      |> List.pop_at(-1)
      # pop_at returns {popped_element, rest}, we only need the rest
      |> elem(1)
      |> Enum.map(&sibling(&1, n))
    end
  end

  @doc """
  The common ancestor of two nodes is the lowest node that is in the
  direct paths of both leaves.
  TODO figure out exactly what this should realistically return
  """
  def common_ancestor_semantic(x, y, n) do
    dx = MapSet.union(MapSet.new([x]), MapSet.new(direct_path(x, n)))
    dy = MapSet.union(MapSet.new([y]), MapSet.new(direct_path(y, n)))

    MapSet.intersection(dx, dy)
  end
end
