#!/usr/bin/env python3
"""50 executable regression scenarios for a Python reference model of main.gd.

Run: python3 test_ddt_reference_50.py
This checks a reference model, NOT Godot runtime. Keep synchronized with main.gd;
independent Godot headless tests are still required before merging.
"""
import math
import unittest
from pathlib import Path

DURATION = 2.6
IMPACT_AT = 1.63
HITSTOP = 0.085

class DDT:
    def __init__(self):
        self.elapsed = 0.0
        self.playing = False
        self.paused = False
        self.reduced = False
        self.hitstop = 0.0
        self.impact = False
        self.speed = 1.0
        self.impact_count = 0

    def restart(self):
        self.elapsed = 0.0
        self.playing = True
        self.paused = False
        self.hitstop = 0.0
        self.impact = False

    def seek(self, t):
        self.elapsed = max(0.0, min(t, DURATION))
        self.playing = False
        self.paused = True
        self.hitstop = 0.0
        self.impact = self.elapsed >= IMPACT_AT

    def set_motion(self, reduced):
        self.reduced = reduced
        if reduced:
            self.hitstop = 0.0

    def set_speed(self, speed):
        self.speed = max(0.25, min(speed, 2.0))

    def tick(self, delta):
        if not self.playing or self.paused:
            return
        if self.reduced and self.hitstop > 0:
            self.hitstop = 0.0
        if self.hitstop > 0:
            self.hitstop = max(0.0, self.hitstop - delta)
        else:
            previous = self.elapsed
            self.elapsed = min(self.elapsed + delta * self.speed, DURATION)
            if not self.impact and previous < IMPACT_AT <= self.elapsed:
                self.elapsed = IMPACT_AT
                self.impact = True
                self.impact_count += 1
                if not self.reduced:
                    self.hitstop = HITSTOP
            if self.elapsed >= DURATION:
                self.playing = False

def phase(t):
    if t < 0.42: return "APPROACH"
    if t < 0.92: return "DOUBLE UNDERHOOK"
    if t < 1.24: return "HOLD / ANTICIPATION"
    if t < 1.63: return "DDT DROP"
    if t < 1.88: return "IMPACT"
    return "RECOVERY"

class FiftyRegressions(unittest.TestCase):
    def test_01_to_10_seek_boundaries(self):
        values = [-100, -1, -0.01, 0, 0.4, 1.63, 2.6, 2.61, 10, 100]
        for i, value in enumerate(values, 1):
            with self.subTest(checkpoint=i):
                m = DDT(); m.restart(); m.seek(value)
                self.assertEqual(m.elapsed, max(0, min(value, DURATION)))
                self.assertFalse(m.playing)
                self.assertTrue(m.paused)
                self.assertEqual(m.hitstop, 0)
                self.assertEqual(m.impact, m.elapsed >= IMPACT_AT)

    def test_11_to_20_phase_boundaries(self):
        samples = [(0, "APPROACH"), (.419, "APPROACH"),
                   (.42, "DOUBLE UNDERHOOK"), (.919, "DOUBLE UNDERHOOK"),
                   (.92, "HOLD / ANTICIPATION"), (1.239, "HOLD / ANTICIPATION"),
                   (1.24, "DDT DROP"), (1.629, "DDT DROP"),
                   (1.63, "IMPACT"), (1.88, "RECOVERY")]
        for i, (time, expected) in enumerate(samples, 11):
            with self.subTest(checkpoint=i):
                self.assertEqual(phase(time), expected)

    def test_21_to_30_speed_limits(self):
        samples = [(-10, .25), (-1, .25), (0, .25), (.1, .25),
                   (.25, .25), (.5, .5), (1, 1), (1.5, 1.5),
                   (2, 2), (100, 2)]
        for i, (input_speed, expected) in enumerate(samples, 21):
            with self.subTest(checkpoint=i):
                m = DDT(); m.set_speed(input_speed)
                self.assertEqual(m.speed, expected)

    def test_31_to_40_impact_once(self):
        deltas = [.01, .02, .05, .1, .2, .3, .4, .5, .8, 2.0]
        for i, delta in enumerate(deltas, 31):
            with self.subTest(checkpoint=i):
                m = DDT(); m.restart()
                for _ in range(500):
                    m.tick(delta)
                    if not m.playing:
                        break
                self.assertEqual(m.impact_count, 1)
                self.assertTrue(m.impact)
                self.assertAlmostEqual(m.elapsed, DURATION)
                self.assertFalse(m.playing)

    def test_41_to_50_motion_toggle_recovery(self):
        deltas = [.001, .005, .01, .02, .03, .04, .05, .06, .07, .08]
        for i, delta in enumerate(deltas, 41):
            with self.subTest(checkpoint=i):
                m = DDT(); m.restart()
                m.tick(IMPACT_AT)
                self.assertEqual(m.impact_count, 1)
                self.assertAlmostEqual(m.hitstop, HITSTOP)
                m.set_motion(True)
                self.assertEqual(m.hitstop, 0)
                previous = m.elapsed
                m.tick(delta)
                self.assertGreater(m.elapsed, previous)
                self.assertEqual(m.impact_count, 1)
                self.assertEqual(m.hitstop, 0)

if __name__ == "__main__":
    unittest.main(verbosity=2)
