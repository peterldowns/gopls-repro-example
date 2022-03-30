package main

import (
	"testing"

	"github.com/google/go-cmp/cmp"
)

// TestComparison will always fail, and exists just to use go-cmp
// so that we can include it as a dependency
func TestComparison(t *testing.T) {
	t.Parallel()

	a := exampleObject{Name: "Alice", Location: "NYC"}
	b := exampleObject{Name: "Bob", Location: "NYC"}
	diff := cmp.Diff(a, b)
	if diff != "" {
		t.Error(diff)
	}
}
