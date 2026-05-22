const express = require('express');
const cors = require('cors');
const NoSQLDatabase = require('./database');

const app = express();
const PORT = process.env.PORT || 5000;
const db = new NoSQLDatabase();

// Default seed data for NoSQL routines collection
const defaultRoutines = [
  {
    id: 1,
    title: 'Workout',
    time: '6 AM to 8 PM',
    category: 'Workout',
    frequency: '3 day a week',
    streak: 9,
    isCompleted: true,
    completedTime: '5:15 AM'
  },
  {
    id: 2,
    title: 'Drink Water',
    time: 'All day',
    category: 'Drink Water',
    frequency: 'Daily',
    streak: 12,
    isCompleted: true,
    completedTime: '12:00 PM'
  },
  {
    id: 3,
    title: 'Attend Class',
    time: '11 AM to 5 PM',
    category: 'Attend Class',
    frequency: '1 day a week',
    streak: 3,
    isCompleted: false,
    completedTime: null
  },
  {
    id: 4,
    title: 'Design Assignment',
    time: '7 PM to 9 PM',
    category: 'Design Assignment',
    frequency: '2 day a week',
    streak: 5,
    isCompleted: false,
    completedTime: null
  },
  {
    id: 5,
    title: 'Watch Anime',
    time: 'All day',
    category: 'Watch Anime',
    frequency: 'Daily',
    streak: 2,
    isCompleted: false,
    completedTime: null
  }
];

// Async seed database function on startup
async function seedDatabase() {
  try {
    const routines = await db.find('routines');
    if (routines.length === 0) {
      await db.saveAll('routines', defaultRoutines);
      console.log('=== NoSQL DB Seeded: Default routines populated ===');
    }
  } catch (err) {
    console.error('=== NoSQL DB Seeding Failed ===:', err.message);
  }
}
seedDatabase();


app.use(cors());
app.use(express.json());

// Log incoming requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend server is running', database: 'NoSQL JSON DB' });
});

// 1. Get user profile
app.get('/api/profile', async (req, res) => {
  try {
    const profile = await db.findOne('profile');
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: 'Failed to read profile', details: err.message });
  }
});

// 2. Create/Update user profile
app.post('/api/profile', async (req, res) => {
  try {
    const profile = req.body;
    // We treat the profile as a single document collection
    // Clear old profile first, then insert new one
    await db.deleteMany('profile', {});
    const saved = await db.insert('profile', profile);
    res.json({ message: 'Profile saved successfully', profile: saved });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save profile', details: err.message });
  }
});

// 3. Clear user profile / Reset database
app.delete('/api/profile', async (req, res) => {
  try {
    await db.deleteMany('profile', {});
    await db.deleteMany('routines', {});
    res.json({ message: 'Database cleared successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to clear database', details: err.message });
  }
});

// 4. Get all routines
app.get('/api/routines', async (req, res) => {
  try {
    const routines = await db.find('routines');
    res.json(routines);
  } catch (err) {
    res.status(500).json({ error: 'Failed to read routines', details: err.message });
  }
});

// 5. Bulk save routines (overwrites the collection)
app.post('/api/routines', async (req, res) => {
  try {
    const routines = req.body;
    if (!Array.isArray(routines)) {
      return res.status(400).json({ error: 'Routines must be an array' });
    }
    const saved = await db.saveAll('routines', routines);
    res.json({ message: 'Routines saved successfully', count: saved.length });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save routines', details: err.message });
  }
});

// 6. Add a single routine
app.post('/api/routines/add', async (req, res) => {
  try {
    const routine = req.body;
    const inserted = await db.insert('routines', routine);
    res.status(201).json(inserted);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add routine', details: err.message });
  }
});

// 7. Delete a single routine by ID
app.delete('/api/routines/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const result = await db.deleteMany('routines', { id });
    res.json({ message: 'Routine deleted successfully', details: result });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete routine', details: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(`Server is running on port ${PORT}`);
  console.log(`API Health Check: http://localhost:${PORT}/api/health`);
  console.log(`=============================================`);
});
