# SPDX-FileCopyrightText: 2024 Łukasz Niemier <#@hauleth.dev>
#
# SPDX-License-Identifier: MIT

defmodule Ops.UnionTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import RangeGen

  @subject RangeSet

  property "with itself is identity function" do
    check all(set <- range_set()) do
      assert set == @subject.union(set, set)
    end
  end

  property "with empty set is identity function" do
    check all(set <- range_set()) do
      assert set == @subject.union(set, @subject.new())
    end
  end

  property "is commutative" do
    check all(p <- range_set(), q <- range_set()) do
      assert @subject.union(q, p) == @subject.union(p, q)
    end
  end

  property "contains all elements from right set" do
    check all(p <- range_set(), q <- range_set()) do
      union = @subject.union(p, q)

      assert Enum.all?(q, &(&1 in union))
    end
  end

  property "contains all elements from left set" do
    check all(p <- range_set(), q <- range_set()) do
      union = @subject.union(p, q)

      assert Enum.all?(p, &(&1 in union))
    end
  end
end
