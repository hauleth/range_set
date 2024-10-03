# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Ops.DifferenceTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "with itself result in empty set - A ∖ A = ∅" do
    check all(set <- range_set()) do
      assert @subject.empty?(@subject.difference(set, set))
    end
  end

  property "with empty set is identity function - A ∖ ∅ = A" do
    check all(set <- range_set()) do
      assert set == @subject.difference(set, @subject.new())
    end
  end

  property "against empty set is empty set - ∅ ∖ A = ∅" do
    check all(set <- range_set()) do
      assert @subject.empty?(@subject.difference(@subject.new(), set))
    end
  end

  property "elements from the right set aren't in result" do
    check all(p <- range_set(), q <- range_set()) do
      result = @subject.difference(p, q)

      assert Enum.all?(q, &(&1 not in result))
    end
  end

  property "C ∖ (A ∩ B) = (C ∖ A) ∪ (C ∖ B)" do
    check all(a <- range_set(), b <- range_set(), c <- range_set()) do
      c_ab = @subject.difference(c, @subject.intersection(a, b))
      ca_cb = @subject.union(@subject.difference(c, a), @subject.difference(c, b))

      assert c_ab == ca_cb
    end
  end

  property "C ∖ (A ∪ B) = (C ∖ A) ∩ (C ∖ B)" do
    check all(a <- range_set(), b <- range_set(), c <- range_set()) do
      c_ab = @subject.difference(c, @subject.union(a, b))
      ca_cb = @subject.intersection(@subject.difference(c, a), @subject.difference(c, b))

      assert c_ab == ca_cb
    end
  end

  property "single element `a` is treated the same as range `a..a`" do
    check all(p <- range_set(), a <- integer()) do
      diff1 = @subject.difference(p, a)
      diff2 = @subject.difference(p, a..a)

      assert diff1 == diff2
    end
  end
end
