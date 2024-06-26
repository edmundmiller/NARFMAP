#ifndef DRAGENOS_WORKFLOW_GEN_HASH_TABLE_WORKFLOW_HPP
#define DRAGENOS_WORKFLOW_GEN_HASH_TABLE_WORKFLOW_HPP

#include <string>
#include <vector>

// Forward declarations
namespace options {
class DragenOsOptions;
}

struct hashTableConfig_t;

namespace dragenos {
namespace workflow {

enum HashTableType {
    HT_TYPE_NORMAL,
    HT_TYPE_METHYL_G_TO_A,
    HT_TYPE_METHYL_C_TO_T,
    HT_TYPE_ANCHORED
};

std::string GetFullPath(const std::string& p);

bool ReferenceAutoDetectValidate(const options::DragenOsOptions& opts);

std::string GetReferenceAutoDetectDir(const options::DragenOsOptions& opts);

void getRelativeLiftoverPath(const std::string& oldPath, std::string& newPath);

void SetBuildHashTableOptions(
    const options::DragenOsOptions& opts,
    hashTableConfig_t* config,
    HashTableType hashTableType
);

void FreeBuildHashTableOptions(hashTableConfig_t* config);

void uncompressHashCmp(const options::DragenOsOptions& opts);

void buildHashTable(const options::DragenOsOptions& opts);

} // namespace workflow
} // namespace dragenos

#endif // DRAGENOS_WORKFLOW_GEN_HASH_TABLE_WORKFLOW_HPP
