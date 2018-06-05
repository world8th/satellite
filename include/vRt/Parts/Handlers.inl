#pragma once
#include "Headers.inl"
#include "HardClasses.inl"

// class aliases for vRt from C++ hard implementators (incomplete)
// use shared pointers for C++
// (planned use plain pointers in C)
namespace vt { // store in official namespace

    struct VtInstance {
        std::shared_ptr<_vt::Instance> _vtInstance;
        operator VkInstance() const { return *_vtInstance; }
        operator bool() const { return !!_vtInstance; };
    };

    struct VtPhysicalDevice {
        std::shared_ptr<_vt::PhysicalDevice> _vtPhysicalDevice;
        operator VkPhysicalDevice() const { return *_vtPhysicalDevice; }
        operator bool() const { return !!_vtPhysicalDevice; };
    };

    struct VtDevice {
        std::shared_ptr<_vt::Device> _vtDevice;
        operator VkDevice() const { return *_vtDevice; }
        operator bool() const { return !!_vtDevice; };
    };

    struct VtCommandBuffer {
        std::shared_ptr<_vt::CommandBuffer> _vtCommandBuffer;
        operator VkCommandBuffer() const { return *_vtCommandBuffer; }
        operator bool() const { return !!_vtCommandBuffer; };
    };

    struct VtPipelineLayout {
        std::shared_ptr<_vt::PipelineLayout> _vtPipelineLayout;
        operator VkPipelineLayout() const { return *_vtPipelineLayout; }
        operator bool() const { return !!_vtPipelineLayout; };
    };

    struct VtPipeline {
        std::shared_ptr<_vt::Pipeline> _vtPipeline;
        operator bool() const { return !!_vtPipeline; }
    };

    struct VtAccelerator {
        std::shared_ptr<_vt::Accelerator> _vtAccelerator;
        operator bool() const { return !!_vtAccelerator; }
    };

    struct VtMaterialSet {
        std::shared_ptr<_vt::MaterialSet> _vtMaterialSet;
        operator VkDescriptorSet() const { return *_vtMaterialSet; }
        operator bool() const { return !!_vtMaterialSet; }
    };

    // advanced class (buffer)
    struct VtDeviceBuffer {
        std::shared_ptr<_vt::DeviceBuffer> _vkDeviceBuffer;
        operator VkBuffer() const { return *_vkDeviceBuffer; }
        operator VkBufferView() const { return *_vkDeviceBuffer; }
        operator bool() const { return !!_vkDeviceBuffer; }
    };

    // advanced class (image)
    struct VtDeviceImage {
        std::shared_ptr<_vt::DeviceImage> _vkDeviceImage;
        operator VkImage() const { return *_vkDeviceImage; }
        operator VkImageView() const { return *_vkDeviceImage; }
        operator bool() const { return !!_vkDeviceImage; }
    };

};