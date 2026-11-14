"""Tests for answer checking. Run with: python -m unittest test_check"""

import unittest

from spanish_web import app, check_answer


class CheckAnswerTests(unittest.TestCase):
    def assertAccepted(self, user, correct):
        r = check_answer(user, correct)
        self.assertTrue(r["correct"], f"{user!r} should match {correct!r}: {r}")
        return r

    def assertRejected(self, user, correct):
        r = check_answer(user, correct)
        self.assertFalse(r["correct"], f"{user!r} should not match {correct!r}")
        return r

    def test_exact_and_punctuation(self):
        self.assertAccepted("מה שלומך", "מה שלומך?")
        self.assertAccepted("  את החשבון בבקשה ", "את החשבון, בבקשה")
        self.assertAccepted("רגע אחד!!", "רגע אחד!")

    def test_niqqud_ignored(self):
        self.assertAccepted("שָׁלוֹם", "שלום")

    def test_feminine_forms(self):
        self.assertAccepted("אני רעבה", "אני רעב")
        self.assertAccepted("אני מצטערת", "אני מצטער")
        self.assertAccepted("אני צריכה רופא", "אני צריך רופא")
        self.assertAccepted("אני סטודנטית", "אני סטודנט")
        self.assertAccepted("אני עייפה", "אני עייף")
        self.assertAccepted("את צודקת", "אתה צודק")
        self.assertAccepted("בת כמה את?", "בן כמה אתה?")
        self.assertAccepted("אני משועממת", "אני משועמם")

    def test_spelling_alternatives(self):
        self.assertAccepted("אני מאד אוהב את זה", "אני מאוד אוהב את זה")
        self.assertAccepted("זה רעיון טוב", "זו רעיון טוב")

    def test_typo_accepted_with_note(self):
        r = self.assertAccepted("המוזיקה מרגיעה אותי", "המוזיקה מרגיעה אותי")
        self.assertEqual(r["notes"], [])
        r = self.assertAccepted("המוסיקה מרגיעה אותי", "המוזיקה מרגיעה אותי")
        self.assertEqual(len(r["notes"]), 1)
        self.assertIn("המוסיקה", r["notes"][0])

    def test_short_words_must_be_exact(self):
        self.assertRejected("זה קר", "זה רע")

    def test_word_order_accepted_with_note(self):
        r = self.assertAccepted("אתמול הלכתי לשוק", "הלכתי לשוק אתמול")
        self.assertTrue(any("סדר" in n for n in r["notes"]))

    def test_missing_word_single_issue(self):
        r = self.assertRejected("אני אוהב לרקוד", "אני מאוד אוהב לרקוד")
        self.assertEqual(r["issues"], ["חסרה המילה: «מאוד»"])

    def test_extra_word_single_issue(self):
        r = self.assertRejected("אני מאוד רעב עכשיו", "אני מאוד רעב")
        self.assertEqual(r["issues"], ["מילה מיותרת: «עכשיו»"])

    def test_wrong_word(self):
        r = self.assertRejected("אני רוצה לחם", "אני רוצה מים")
        self.assertEqual(r["issues"], ["«לחם» → צריך להיות «מים»"])

    def test_completely_wrong(self):
        r = self.assertRejected("xx", "אני מסכים")
        self.assertTrue(r["issues"])


class RouteTests(unittest.TestCase):
    def setUp(self):
        self.c = app.test_client()
        self.c.get("/select/spanish")

    def test_reveal_counts_and_clears_current(self):
        self.c.get("/api/sentence")
        r = self.c.post("/api/reveal").get_json()
        self.assertTrue(r["hebrew"])
        self.assertEqual(self.c.get("/api/stats").get_json()["revealed"], 1)
        # Can't check or reveal again until a new sentence is loaded.
        self.assertEqual(self.c.post("/api/reveal").status_code, 400)
        self.assertEqual(self.c.post("/api/check", json={"answer": r["hebrew"]}).status_code, 400)

    def test_correct_answer_flow(self):
        from spanish_web import SENTENCES
        idx = self.c.get("/api/sentence").get_json()["id"]
        hebrew = SENTENCES["spanish"][idx][1]
        r = self.c.post("/api/check", json={"answer": hebrew}).get_json()
        self.assertTrue(r["correct"])
        self.assertTrue(r["first_try"])

    def test_every_stored_answer_matches_itself(self):
        from spanish_web import SENTENCES
        for lang, pairs in SENTENCES.items():
            for _, hebrew in pairs:
                self.assertTrue(check_answer(hebrew, hebrew)["correct"], (lang, hebrew))


if __name__ == "__main__":
    unittest.main()
