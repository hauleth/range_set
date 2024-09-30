# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Ops.IntersectionTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "intersection with itself is identity function - A ∩ A = A" do
    check all(set <- range_set()) do
      assert set == @subject.intersection(set, set)
    end
  end

  property "with empty set result in empty set - A ∩ ∅ = ∅" do
    check all(set <- range_set()) do
      assert @subject.empty?(@subject.intersection(set, @subject.new()))
    end
  end

  property "intersection with superset is identity function - A'⊃A => A' ∩ A = A" do
    check all(set <- range_set(), not @subject.empty?(set)) do
      min = @subject.min(set)
      max = @subject.max(set)

      superset = @subject.new((min - 1)..(max + 1))

      assert set == @subject.intersection(set, superset)
    end
  end

  property "is commutative - A ∩ B = B ∩ A" do
    check all(a <- range_set(), b <- range_set()) do
      assert @subject.intersection(a, b) == @subject.intersection(b, a)
    end
  end

  property "is associative - A ∩ (B ∩ C) = (A ∩ B) ∩ C" do
    check all(
      a <- range_set(),
      b <- range_set(),
      c <- range_set()
    ) do
      a_bc = @subject.intersection(a, @subject.intersection(b, c))
      ab_c = @subject.intersection(@subject.intersection(a, b), c)

      assert a_bc == ab_c
    end
  end

  property "is distributive wrt. union - A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)" do
    check all(
      a <- range_set(),
      b <- range_set(),
      c <- range_set()
    ) do
      a_bc = @subject.intersection(a, @subject.union(b, c))
      ab_ac = @subject.union(@subject.intersection(a, b), @subject.intersection(a, c))

      assert a_bc == ab_ac
    end
  end

  property "element of left set is member of intersection if it is also member of right set" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert Enum.all?(p, &(&1 in inter == &1 in q))
    end
  end

  property "element of right set is member of intersection if it is also member of right set" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert Enum.all?(q, &(&1 in inter == &1 in p))
    end
  end

  property "absorbed into union - A ∩ (A ∪ B) = A" do
    check all(a <- range_set(), b <- range_set()) do
      assert a == @subject.intersection(a, @subject.union(a, b))
    end
  end

  property "can be defined in terms of difference - A ∩ B = A ∖ (A ∖ B)" do
    check all(a <- range_set(), b <- range_set()) do
      assert @subject.intersection(a, b) == @subject.difference(a, @subject.difference(a, b))
    end
  end

  property "is proper RangeSet" do
    check all(p <- range_set(), q <- range_set()) do
      inter = @subject.intersection(p, q)
      assert inter == @subject.new(inter.ranges)
    end
  end
end
