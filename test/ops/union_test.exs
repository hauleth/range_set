# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Ops.UnionTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "with itself is identity function - A ∪ A = A" do
    check all(set <- range_set()) do
      assert set == @subject.union(set, set)
    end
  end

  property "with empty set is identity function - A ∪ ∅ = A" do
    check all(set <- range_set()) do
      assert set == @subject.union(set, @subject.new())
    end
  end

  property "is commutative - A ∪ B = B ∪ A" do
    check all(a <- range_set(), b <- range_set()) do
      assert @subject.union(a, b) == @subject.union(b, a)
    end
  end

  property "is associative - A ∪ (B ∪ C) = (A ∪ B) ∪ C" do
    check all(
      a <- range_set(),
      b <- range_set(),
      c <- range_set()
    ) do
      a_bc = @subject.union(a, @subject.union(b, c))
      ab_c = @subject.union(@subject.union(a, b), c)

      assert a_bc == ab_c
    end
  end

  property "is distributive wrt. intersection - A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C)" do
    check all(
      a <- range_set(),
      b <- range_set(),
      c <- range_set()
    ) do
      a_bc = @subject.union(a, @subject.intersection(b, c))
      ab_ac = @subject.intersection(@subject.union(a, b), @subject.union(a, c))

      assert a_bc == ab_ac
    end
  end

  property "contains all elements from right set - A ∪ B = C => ∀x∈A: x∈C" do
    check all(a <- range_set(), b <- range_set()) do
      union = @subject.union(a, b)

      assert Enum.all?(a, &(&1 in union))
    end
  end

  property "contains all elements from left set - A ∪ B = C => ∀x∈B: x∈C" do
    check all(a <- range_set(), b <- range_set()) do
      union = @subject.union(a, b)

      assert Enum.all?(b, &(&1 in union))
    end
  end

  property "absorbed into intersection - A ∪ (A ∩ B) = A" do
    check all(a <- range_set(), b <- range_set()) do
      assert a == @subject.union(a, @subject.intersection(a, b))
    end
  end

  property "is proper RangeSet" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert inter == @subject.new(inter.ranges)
    end
  end
end
