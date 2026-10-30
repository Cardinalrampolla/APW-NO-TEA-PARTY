# Team A Candidate 45 — code review patch
Repository full build is NOT included in this commit. Candidate 45 is a 22 MB standalone HTML file and cannot be transferred through the available GitHub connector in this session.

The following is the exact source change between Candidate 44 and Candidate 45, around line 10322 of the standalone HTML:

```diff
--- candidate44
+++ candidate45
@@ -10322,7 +10322,7 @@
         return rect.left + rect.width / 2;
       };
       const ringWidth = ring.getBoundingClientRect().width || 600;
-      // Place the lead at the visible victim art and the assistant one half-sprite behind.
+      // Keep the lead near the victim silhouette and the assistant behind the lead.
       // Wrapper boxes contain transparent sprite margins, so edge-to-edge boxes leave a gap.
       // Read layout positions before applying either transform to avoid feedback.
       const direction = side === 0 ? -1 : 1;
@@ -10333,8 +10333,8 @@
       // the victim while the assistant stays a visible half-step behind.
       const destinations = () => {
         const victimX = centerX(target);
-        const leadX = victimX + direction * (victimWidth * 0.22 + leadWidth * 0.18);
-        const assistX = leadX + direction * (leadWidth * 0.43 + assistWidth * 0.33);
+        const leadX = victimX + direction * (victimWidth * 0.08 + leadWidth * 0.05);
+        const assistX = leadX + direction * (leadWidth * 0.22 + assistWidth * 0.18);
         return [leadX, assistX];
       };
       const travelFor = (node, destination) => Math.round(cap(
```

Review focus: Are the contact offsets stable for both tag sides, all wrestler sizes, transforms, and viewport sizes? Are lead/assist positions independent of animation feedback? Are visual sprite bounds actually measured? Is the contact frame obscured by banners? Review the full HTML separately for comprehensive conclusions.
