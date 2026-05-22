const fs = require('fs').promises;
const path = require('path');

class NoSQLDatabase {
  constructor(dataDir) {
    this.dataDir = dataDir || path.join(__dirname, 'data');
  }

  async _ensureDir() {
    try {
      await fs.mkdir(this.dataDir, { recursive: true });
    } catch (err) {
      if (err.code !== 'EEXIST') throw err;
    }
  }

  async _getFilePath(collection) {
    await this._ensureDir();
    return path.join(this.dataDir, `${collection}.json`);
  }

  async _readCollection(collection) {
    const filePath = await this._getFilePath(collection);
    try {
      const data = await fs.readFile(filePath, 'utf8');
      return JSON.parse(data);
    } catch (err) {
      if (err.code === 'ENOENT') {
        return [];
      }
      throw err;
    }
  }

  async _writeCollection(collection, data) {
    const filePath = await this._getFilePath(collection);
    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
  }

  // Matches a document against a query (e.g., { id: 1 } or { username: 'john' })
  _matches(doc, query) {
    for (const key in query) {
      if (doc[key] !== query[key]) {
        return false;
      }
    }
    return true;
  }

  async find(collection, query = {}) {
    const data = await this._readCollection(collection);
    return data.filter(doc => this._matches(doc, query));
  }

  async findOne(collection, query = {}) {
    const data = await this._readCollection(collection);
    return data.find(doc => this._matches(doc, query)) || null;
  }

  async insert(collection, doc) {
    const data = await this._readCollection(collection);
    // Generate id if not present and is routine
    if (!doc.id && collection === 'routines') {
      const maxId = data.reduce((max, d) => (d.id > max ? d.id : max), 0);
      doc.id = maxId + 1;
    }
    data.push(doc);
    await this._writeCollection(collection, data);
    return doc;
  }

  async update(collection, query, updateObj, options = { upsert: false }) {
    const data = await this._readCollection(collection);
    let matched = false;

    const updatedData = data.map(doc => {
      if (this._matches(doc, query)) {
        matched = true;
        // Merge updates
        return { ...doc, ...updateObj };
      }
      return doc;
    });

    if (!matched && options.upsert) {
      const newDoc = { ...query, ...updateObj };
      updatedData.push(newDoc);
      await this._writeCollection(collection, updatedData);
      return newDoc;
    }

    await this._writeCollection(collection, updatedData);
    return updatedData.filter(doc => this._matches(doc, query));
  }

  async deleteMany(collection, query) {
    const data = await this._readCollection(collection);
    const remaining = data.filter(doc => !this._matches(doc, query));
    await this._writeCollection(collection, remaining);
    return { deletedCount: data.length - remaining.length };
  }

  async saveAll(collection, documents) {
    await this._writeCollection(collection, documents);
    return documents;
  }
}

module.exports = NoSQLDatabase;
