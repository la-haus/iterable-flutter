package com.lahaus.iterable_flutter

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import com.iterable.iterableapi.ui.inbox.InboxMode
import com.iterable.iterableapi.ui.inbox.IterableInboxFragment

class MobileInboxActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mobile_inbox)
        initAppBar()
        setupInbox()
    }

    private fun initAppBar() {
        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        // Title
        intent.getStringExtra("activityTitle")?.let {
            toolbar.title = it
        }
        // Show back button
        setSupportActionBar(toolbar)
        supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
        }
    }

    private fun setupInbox() {
        // Params
        val noMessagesTitle = intent.getStringExtra("noMessagesTitle")
        val noMessagesBody = intent.getStringExtra("noMessagesBody")
        // Create Inbox Fragment
        val fragment =
            IterableInboxFragment.newInstance(InboxMode.POPUP, 0, noMessagesTitle, noMessagesBody)
        // Commit Fragment
        supportFragmentManager.beginTransaction().apply {
            add(R.id.fragmentContainer, fragment, null)
            commitAllowingStateLoss()
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}